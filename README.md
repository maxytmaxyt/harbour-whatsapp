<div align="center">

# 💬 harbour-whatsapp

**WhatsApp Web as a native Sailfish OS app**

[![Build RPM](https://github.com/maxytmaxyt/harbour-whatsapp/actions/workflows/build.yml/badge.svg)](https://github.com/maxytmaxyt/harbour-whatsapp/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Sailfish OS](https://img.shields.io/badge/Sailfish%20OS-3.0%2B-blue.svg)](https://sailfishos.org)
[![QML](https://img.shields.io/badge/Language-QML%20%2F%20C%2B%2B-orange.svg)](https://doc.qt.io/qt-5/qtqml-index.html)
[![Version](https://img.shields.io/badge/Version-1.2.0-brightgreen.svg)](https://github.com/maxytmaxyt/harbour-whatsapp/releases)

Wraps [WhatsApp Web](https://web.whatsapp.com) in a proper **Silica UI** with cover page, background notifications, privacy mode, and native Sailfish gestures.

</div>

---

## ✨ Features

| Feature | Details |
|---|---|
| 🌊 **Native Silica UI** | Looks and feels like a real Sailfish OS app |
| 📱 **QtWebView embed** | Full WhatsApp Web rendered on-device |
| 🎨 **WhatsApp dark theme** | Matches the `#111B21` palette of WA Web |
| 🔄 **Pull-down menu** | Settings · Reload · Open in Browser · About |
| 📟 **Cover with unread badge** | Unread message count visible on the home screen |
| 🔔 **Background daemon** | Python daemon via D-Bus & systemd for notifications |
| 🔒 **Privacy mode** | Hides content when the app is in the background |
| 💡 **Keep screen on** | Prevents auto-lock while the app is open (MCE D-Bus) |
| 🔤 **Adjustable font size** | Slider in settings, persisted across restarts |
| ↩️ **Back navigation** | Left-edge swipe gesture + hardware back button |
| 🌐 **Android Chrome UA** | Forces WhatsApp Web to serve the mobile interface |
| ✅ **Error page + retry** | Graceful handling of connection failures |
| 🌍 **Translations** | German 🇩🇪 · English 🇬🇧 · Finnish 🇫🇮 |

---

## 📋 Requirements

- **Sailfish OS** 3.0 or newer
- `qt5-qtwebview` installed on the device
- `nemo-qml-plugin-dbus-qt5`
- `nemo-qml-plugin-notifications-qt5`
- `python3` + `python3-dbus` (for the notification daemon)
- Internet connection
- A WhatsApp account (QR code scan on first launch)

---

## 📦 Installation

### Pre-built RPM (recommended)

Download the latest `.rpm` for your device architecture from the [**Releases**](https://github.com/maxytmaxyt/harbour-whatsapp/releases) page:

| Architecture | Device type |
|---|---|
| `aarch64` | Most modern Sailfish phones (e.g. Xperia 10 II/III/IV/V) |
| `armv7hl` | Older 32-bit ARM devices (e.g. Jolla 1, Xperia X) |
| `i486` | Sailfish OS emulator / SDK |

Then install with:

```bash
pkcon install-local harbour-whatsapp-<version>.<arch>.rpm
```

Or copy the RPM to your device and install it via the Sailfish file manager.

### Build from source

#### Using Sailfish SDK (recommended)

1. Install the [Sailfish SDK](https://docs.sailfishos.org/Tools/Sailfish_SDK/)
2. Open **Sailfish IDE** → *File → Open Project* → select `harbour-whatsapp.pro`
3. Choose your target architecture and hit **Build**

Or via CLI inside the SDK build environment:

```bash
sfdk build
sfdk deploy --sdk
```

#### Manual RPM build with mb2

```bash
git clone https://github.com/maxytmaxyt/harbour-whatsapp.git
cd harbour-whatsapp
mb2 build
```

The built `.rpm` files end up in `RPMS/`.

---

## 🗂️ Project Structure

```
harbour-whatsapp/
├── src/
│   ├── harbour-whatsapp.cpp              # C++ entry point – initialises QtWebView
│   └── daemon/
│       └── harbour-whatsapp-daemon.py    # Background notification daemon (Python)
├── qml/
│   ├── harbour-whatsapp.qml             # ApplicationWindow root + persisted settings
│   ├── pages/
│   │   ├── MainPage.qml                 # WebView + loading / error states
│   │   ├── AboutPage.qml               # About screen
│   │   └── SettingsPage.qml            # Settings: privacy, screen, font size
│   └── cover/
│       └── CoverPage.qml               # Sailfish cover with unread count
├── icons/
│   ├── 86x86/harbour-whatsapp.png      # App icon (Sailfish home screen)
│   ├── 108x108/harbour-whatsapp.png
│   ├── 128x128/harbour-whatsapp.png
│   └── 172x172/harbour-whatsapp.png
├── dbus/
│   └── net.maxyt.WhatsApp.service       # D-Bus session service file
├── systemd/
│   └── harbour-whatsapp-daemon.service  # systemd user unit for the daemon
├── translations/
│   ├── harbour-whatsapp-de.ts          # German translation
│   ├── harbour-whatsapp-en.ts          # English translation
│   └── harbour-whatsapp-fi.ts          # Finnish translation
├── rpm/
│   └── harbour-whatsapp.spec           # RPM packaging spec
├── .github/
│   ├── workflows/
│   │   └── build.yml                   # CI: builds RPMs for all 3 architectures
│   └── ISSUE_TEMPLATE/
│       ├── feature_request.md          # Feature request template
│       └── bug_report.md               # Bug report template
├── harbour-whatsapp.pro                # Qt project file
├── harbour-whatsapp.desktop            # Sailfish desktop entry
├── FEATURE_WISHLIST.md                 # Community feature wishlist
├── CONTRIBUTING.md                     # Contribution guide
└── LICENSE                            # MIT
```

---

## ⚙️ Architecture overview

```
┌─────────────────────────────────────┐
│         Sailfish Home Screen        │
│   ┌─────────────────────────────┐   │
│   │  CoverPage.qml              │   │
│   │  (unread badge via D-Bus)   │   │
│   └─────────────────────────────┘   │
└──────────────┬──────────────────────┘
               │ app launch
┌──────────────▼──────────────────────┐
│   harbour-whatsapp.cpp              │
│   (Qt/C++ entry point)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   harbour-whatsapp.qml              │
│   (ApplicationWindow + Settings)    │
│   ├── MainPage.qml (QtWebView)      │
│   │   → web.whatsapp.com            │
│   │   → Android Chrome UA           │
│   │   → Privacy overlay             │
│   ├── SettingsPage.qml              │
│   └── AboutPage.qml                 │
└─────────────────────────────────────┘

Background:
┌─────────────────────────────────────┐
│   harbour-whatsapp-daemon.py        │
│   (systemd user service)            │
│   → checks unread count via WA Web  │
│   → exposes count on D-Bus          │
│   → CoverPage reads D-Bus value     │
└─────────────────────────────────────┘
```

---

## 📝 Notes

- **Session persistence** — QtWebView stores local data, so you only need to scan the QR code once.
- **Notifications** — The background daemon exposes unread counts via D-Bus. Push notifications from WhatsApp's server are not available (Sailfish has no FCM bridge).
- **User-Agent** — An Android Chrome UA is injected so WA Web serves its mobile-optimised interface instead of the desktop one.
- **Resource limits** — The daemon is capped at 5 % CPU and 64 MB RAM to be a good citizen on the device.
- **Privacy mode** — When enabled, a solid overlay is shown immediately when the app leaves the foreground, preventing WhatsApp content from appearing in the task switcher or cover preview.

---

## 💡 Feature requests

Got an idea? Check the [**Feature Wishlist**](FEATURE_WISHLIST.md) to see what's already planned, then open a [💡 Feature Request](https://github.com/maxytmaxyt/harbour-whatsapp/issues/new?template=feature_request.md) issue — I read every one!

---

## 🤝 Contributing

Pull requests are welcome! Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** before opening a PR.

---

## 📄 License

[MIT](LICENSE) © maxytmaxyt
