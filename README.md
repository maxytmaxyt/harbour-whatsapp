<div align="center">

# 💬 harbour-whatsapp

**WhatsApp Web as a native Sailfish OS app**

[![Build RPM](https://github.com/maxytmaxyt/harbour-whatsapp/actions/workflows/build.yml/badge.svg)](https://github.com/maxytmaxyt/harbour-whatsapp/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Sailfish OS](https://img.shields.io/badge/Sailfish%20OS-3.0%2B-blue.svg)](https://sailfishos.org)
[![QML](https://img.shields.io/badge/Language-QML%20%2F%20C%2B%2B-orange.svg)](https://doc.qt.io/qt-5/qtqml-index.html)

Wraps [WhatsApp Web](https://web.whatsapp.com) in a proper **Silica UI** with cover page, background notifications, and native Sailfish gestures.

</div>

---

## ✨ Features

| Feature | Details |
|---|---|
| 🌊 **Native Silica UI** | Looks and feels like a real Sailfish OS app |
| 📱 **QtWebView embed** | Full WhatsApp Web rendered on-device |
| 🎨 **WhatsApp dark theme** | Matches the `#111B21` palette of WA Web |
| 🔄 **Pull-down menu** | Reload · Open in Browser · About |
| 📟 **Cover with unread badge** | Unread message count visible on the home screen |
| 🌐 **Android Chrome User-Agent** | Forces WhatsApp Web to serve the mobile interface |
| ✅ **Error page + retry** | Graceful handling of connection failures |
| 🔔 **Background daemon** | Python daemon via D-Bus & systemd for notifications |
| ↩️ **Hardware back button** | Navigates back in web history |
| 🇩🇪 **German translation** | Included out of the box |

---

## 📋 Requirements

- **Sailfish OS** 3.0 or newer
- `qt5-qtwebview` installed on the device
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
│   ├── harbour-whatsapp.qml             # ApplicationWindow root
│   ├── pages/
│   │   ├── MainPage.qml                 # WebView + loading / error states
│   │   └── AboutPage.qml               # About screen
│   └── cover/
│       └── CoverPage.qml               # Sailfish cover with unread count
├── dbus/
│   └── net.maxyt.WhatsApp.service       # D-Bus session service file
├── systemd/
│   └── harbour-whatsapp-daemon.service  # systemd user unit for the daemon
├── translations/
│   └── harbour-whatsapp-de.ts          # German translation source
├── rpm/
│   └── harbour-whatsapp.spec           # RPM packaging spec
├── .github/
│   └── workflows/
│       └── build.yml                   # CI: builds RPMs for all 3 architectures
├── harbour-whatsapp.pro                # Qt project file
├── harbour-whatsapp.desktop            # Sailfish desktop entry
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
│   MainPage.qml (QtWebView)          │
│   → web.whatsapp.com                │
│   → Android Chrome UA               │
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

---

## 🤝 Contributing

Pull requests are welcome! Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** before opening a PR.

---

## 📄 License

[MIT](LICENSE) © maxytmaxyt
