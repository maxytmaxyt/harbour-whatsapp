# WhatsApp for Sailfish OS

A native Sailfish OS app that wraps [WhatsApp Web](https://web.whatsapp.com) in a proper Silica interface.

## Features

- 🌊 Native Sailfish OS look & feel (Silica UI)
- 📱 WhatsApp Web embedded via QtWebView
- 🎨 WhatsApp-themed dark UI (`#111B21`)
- 🔄 Pull-down menu: Reload / Open in Browser / About
- 📟 Cover page with unread message count
- 🌐 Android Chrome User-Agent for full WA Web compatibility
- ✅ Error page with retry on connection failure
- 🇩🇪 German translation included
- ↩️ Hardware back-button navigates back in web history

## Requirements

- Sailfish OS 3.0+
- `qt5-qtwebview` package installed on device
- Internet connection
- WhatsApp account (scan QR code on first launch)

## Building

### In Sailfish SDK (Scratchbox2)

```bash
# Open Sailfish IDE and import the project
# Or build via CLI:
sfdk build
sfdk deploy --sdk
```

### Manual RPM build

```bash
mb2 build
```

## Installation

Install the generated `.rpm` from `RPMS/` directory:

```bash
pkcon install-local harbour-whatsapp-1.0.0-1.noarch.rpm
```

## Project Structure

```
harbour-whatsapp/
├── src/
│   └── harbour-whatsapp.cpp      # C++ entry point (initializes QtWebView)
├── qml/
│   ├── harbour-whatsapp.qml      # ApplicationWindow
│   ├── pages/
│   │   ├── MainPage.qml          # WebView + loading/error states
│   │   └── AboutPage.qml         # About screen
│   └── cover/
│       └── CoverPage.qml         # Sailfish cover with unread count
├── translations/
│   └── harbour-whatsapp-de.ts    # German translation
├── rpm/
│   └── harbour-whatsapp.spec     # RPM packaging spec
├── harbour-whatsapp.pro          # Qt project file
├── harbour-whatsapp.desktop      # Desktop entry
└── README.md
```

## Notes

- Session data is persisted by QtWebView's local storage, so you only need to scan the QR code once
- Notifications are disabled (Sailfish OS doesn't have a bridge for web notifications)
- The app uses an Android Chrome UA so WhatsApp Web serves the mobile interface

## License

MIT — see [LICENSE](LICENSE)
