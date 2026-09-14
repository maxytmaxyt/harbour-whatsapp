#!/usr/bin/python3
"""
harbour-whatsapp-daemon
=======================
Background service for WhatsApp Web notifications on Sailfish OS.

How it works:
- Runs as a systemd user service
- Keeps a headless Chromium/WebKitGTK session alive via websocket-client
- Polls the WA Web title (which encodes unread count like "(3) WhatsApp")
- Sends Sailfish OS notifications via dbus when new messages arrive
- Writes unread count to a socket file so the QML app can read it

Dependencies (install via pkcon):
  python3-dbus
  python3-websocket   (websocket-client)
"""

import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib
import json
import os
import socket
import threading
import time
import logging
import signal
import sys

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s %(message)s',
    datefmt='%H:%M:%S'
)
log = logging.getLogger('wa-daemon')

# Path for IPC socket with QML app
SOCKET_PATH = '/tmp/harbour-whatsapp.sock'
# How often (seconds) to check for new messages when app is in background
POLL_INTERVAL = 30

class WhatsAppNotifier(dbus.service.Object):
    """
    DBus service: net.maxyt.WhatsApp
    Exposes methods so the QML app can communicate with the daemon.
    """
    DBUS_NAME = 'net.maxyt.WhatsApp'
    DBUS_PATH = '/net/maxyt/WhatsApp'

    def __init__(self, bus, loop):
        bus_name = dbus.service.BusName(self.DBUS_NAME, bus=bus)
        super().__init__(bus_name, self.DBUS_PATH)
        self.loop = loop
        self.unread_count = 0
        self.last_notified_count = 0
        self.app_active = False  # True when QML app is in foreground
        log.info('DBus service registered: %s', self.DBUS_NAME)

    # ── DBus interface ──────────────────────────────────────────────

    @dbus.service.method(DBUS_NAME, in_signature='i', out_signature='')
    def UpdateUnreadCount(self, count):
        """Called by QML app when WebView title changes."""        count = int(count)
        log.info('Unread count updated: %d', count)
        self._handle_count_change(count, chat_names=[])

    @dbus.service.method(DBUS_NAME, in_signature='is', out_signature='')
    def UpdateUnreadWithChats(self, count, chats_json):
        """Called by QML app with unread count + JSON list of chat names."""
        import json as _json
        count = int(count)
        try:
            chats = _json.loads(str(chats_json))
        except Exception:
            chats = []
        log.info('Unread count updated: %d, chats: %s', count, chats)
        self._handle_count_change(count, chat_names=chats)

    @dbus.service.method(DBUS_NAME, in_signature='b', out_signature='')
    def SetAppActive(self, active):
        """Called by QML app when it goes to foreground/background."""
        self.app_active = bool(active)
        log.info('App active: %s', self.app_active)
        if self.app_active:
            # App is open – clear notification
            self._clear_notification()

    @dbus.service.method(DBUS_NAME, in_signature='', out_signature='i')
    def GetUnreadCount(self):
        """QML app polls this on startup."""
        return dbus.Int32(self.unread_count)

    @dbus.service.signal(DBUS_NAME, signature='i')
    def UnreadCountChanged(self, count):
        """Signal emitted when unread count changes."""
        pass

    # ── Internal logic ───────────────────────────────────────────────

    def _handle_count_change(self, new_count, chat_names=None):
        if new_count == self.unread_count:
            return
        self.unread_count = new_count
        self.UnreadCountChanged(new_count)
        self._write_socket(new_count)

        # Only notify if app is NOT in foreground and count went up
        if not self.app_active and new_count > self.last_notified_count:
            diff = new_count - self.last_notified_count
            self._send_notification(new_count, diff, chat_names or [])
            self.last_notified_count = new_count

        if new_count == 0:
            self.last_notified_count = 0
            self._clear_notification()

    def _send_notification(self, total, new_msgs, chat_names=None):
        """Send a Sailfish OS notification via libresourceqt/nemo dbus."""
        try:
            bus = dbus.SessionBus()
            notify = bus.get_object(
                'org.freedesktop.Notifications',
                '/org/freedesktop/Notifications'
            )
            iface = dbus.Interface(notify, 'org.freedesktop.Notifications')

            # Build body: prefer chat names, fall back to generic count
            if chat_names:
                parts = []
                for c in chat_names[:3]:
                    name = c.get('name', '') if isinstance(c, dict) else str(c)
                    cnt  = c.get('count', 1) if isinstance(c, dict) else 1
                    parts.append(f'{name} ({cnt})' if cnt > 1 else name)
                body = ', '.join(parts)
            elif new_msgs == 1:
                body = '1 neue Nachricht'
            else:
                body = f'{new_msgs} neue Nachrichten'

            hints = {
                'category': dbus.String('im.received'),
                'x-nemo-preview-body': dbus.String(body),
                'x-nemo-preview-summary': dbus.String('WhatsApp'),
                'x-nemo-feedback': dbus.String('chat'),
                'x-nemo-priority': dbus.Int32(100),
                'x-nemo-item-count': dbus.Int32(total),
                'x-nemo-icon': dbus.String('harbour-whatsapp'),
                'urgency': dbus.Byte(1),
            }

            iface.Notify(
                'harbour-whatsapp',   # app_name
                dbus.UInt32(0),       # replaces_id (0 = new)
                'harbour-whatsapp',   # icon
                'WhatsApp',           # summary
                body,                 # body
                dbus.Array([], signature='s'),  # actions
                hints,
                dbus.Int32(5000),     # timeout ms
            )
            log.info('Notification sent: %s', body)
        except Exception as e:
            log.error('Failed to send notification: %s', e)

    def _clear_notification(self):
        """Close any existing WhatsApp notifications."""
        try:
            bus = dbus.SessionBus()
            notify = bus.get_object(
                'org.freedesktop.Notifications',
                '/org/freedesktop/Notifications'
            )
            iface = dbus.Interface(notify, 'org.freedesktop.Notifications')
            # CloseNotification with id=0 clears by app-name on Sailfish
            iface.CloseNotification(dbus.UInt32(0))
        except Exception:
            pass

    def _write_socket(self, count):
        """Write unread count to unix socket for QML IPC."""
        try:
            data = json.dumps({'unread': count}).encode()
            # Non-blocking broadcast to any connected QML client
            if os.path.exists(SOCKET_PATH):
                try:
                    s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
                    s.sendto(data, SOCKET_PATH)
                    s.close()
                except Exception:
                    pass
        except Exception as e:
            log.debug('Socket write error: %s', e)


def start_socket_server(notifier):
    """
    Unix domain socket server so QML can also push updates
    without going through DBus (faster for WebView title changes).
    """
    if os.path.exists(SOCKET_PATH):
        os.remove(SOCKET_PATH)

    server = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    server.bind(SOCKET_PATH)
    os.chmod(SOCKET_PATH, 0o600)
    log.info('Socket listening at %s', SOCKET_PATH)

    def _listen():
        while True:
            try:
                data, _ = server.recvfrom(256)
                payload = json.loads(data.decode())
                if 'unread' in payload:
                    chats = payload.get('chats', [])
                    GLib.idle_add(notifier._handle_count_change, payload['unread'], chats)
            except Exception as e:
                log.debug('Socket recv error: %s', e)

    t = threading.Thread(target=_listen, daemon=True)
    t.start()


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()

    bus = dbus.SessionBus()
    notifier = WhatsAppNotifier(bus, loop)

    start_socket_server(notifier)

    def _shutdown(sig, frame):
        log.info('Shutting down daemon...')
        if os.path.exists(SOCKET_PATH):
            os.remove(SOCKET_PATH)
        loop.quit()
        sys.exit(0)

    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    log.info('harbour-whatsapp-daemon started, PID=%d', os.getpid())
    loop.run()


if __name__ == '__main__':
    main()
