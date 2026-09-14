TARGET = harbour-whatsapp

CONFIG += sailfishapp sailfishapp_no_deploy_qml

QT += webview dbus

SOURCES += src/harbour-whatsapp.cpp

OTHER_FILES += \
    rpm/harbour-whatsapp.spec \
    harbour-whatsapp.desktop \
    qml/harbour-whatsapp.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    systemd/harbour-whatsapp-daemon.service \
    src/daemon/harbour-whatsapp-daemon.py \
    translations/*.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-whatsapp-de.ts
