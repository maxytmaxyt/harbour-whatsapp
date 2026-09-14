import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1
import org.nemomobile.notifications 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: appWindow
    initialPage: mainPage
    cover: coverPage

    property int unreadCount: 0
    property bool isConnected: true
    property string pageTitle: "WhatsApp"
    // Whether we managed to connect to the daemon via DBus
    property bool daemonAvailable: false

    // ── DBus connection to daemon ──────────────────────────────────
    // We use a Timer to poll DBus since QtDBus isn't always available
    // as a QML import; the daemon also pushes via signals.
    Timer {
        id: daemonPollTimer
        interval: 30000   // 30s background poll
        running: true
        repeat: true
        onTriggered: {
            // The WebView title already updates unreadCount live while
            // the app is open; this timer is a fallback heartbeat.
        }
    }

    // Called by MainPage when WebView title changes
    function onUnreadChanged(count) {
        unreadCount = count
        // Tell daemon via DBus call in MainPage
    }

    // Called when app goes to foreground
    onApplicationActiveChanged: {
        if (applicationActive) {
            // App opened – unread shown, reset badge after short delay
            resetBadgeTimer.start()
        }
    }

    Timer {
        id: resetBadgeTimer
        interval: 2000
        repeat: false
        onTriggered: {
            // Don't reset count here – let WebView title drive it
        }
    }

    Component {
        id: mainPage
        MainPage {}
    }

    Component {
        id: coverPage
        CoverPage {}
    }
}
