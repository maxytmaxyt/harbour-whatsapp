import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1
import Nemo.DBus 2.0
import Nemo.Notifications 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    readonly property string userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
    readonly property string whatsappUrl: "https://web.whatsapp.com"

    property bool isLoading: true
    property bool hasError: false
    property string errorText: ""
    property bool webReady: false

    // ── DBus interface to daemon ───────────────────────────────────
    DBusInterface {
        id: daemonDbus
        service:   'net.maxyt.WhatsApp'
        path:      '/net/maxyt/WhatsApp'
        iface:     'net.maxyt.WhatsApp'
        bus:       DBus.SessionBus

        Component.onCompleted: {
            // Tell daemon app is now active (foreground)
            call('SetAppActive', [true])
        }
    }

    // ── Sailfish Notification ──────────────────────────────────────
    Notification {
        id: waNotification
        appName:  "WhatsApp"
        appIcon:  "harbour-whatsapp"
        category: "x-nemo.messaging.im"
        // remoteActions: open app when tapped
        remoteActions: [{
            "name":        "default",
            "displayName": "Öffnen",
            "icon":        "harbour-whatsapp",
            "service":     "net.maxyt.WhatsApp",
            "path":        "/net/maxyt/WhatsApp",
            "iface":       "net.maxyt.WhatsApp",
            "method":      "Activate",
            "arguments":   []
        }]
    }

    function sendNotification(unread, prev) {
        var diff = unread - prev
        if (diff <= 0) return
        waNotification.summary = "WhatsApp"
        waNotification.body = diff === 1
            ? "Du hast 1 neue Nachricht"
            : "Du hast " + diff + " neue Nachrichten"
        waNotification.itemCount = unread
        waNotification.publish()
    }

    // ── App lifecycle ──────────────────────────────────────────────
    Connections {
        target: appWindow
        onApplicationActiveChanged: {
            if (appWindow.applicationActive) {
                daemonDbus.call('SetAppActive', [true])
                // Clear notifications when user opens app
                waNotification.close()
            } else {
                daemonDbus.call('SetAppActive', [false])
            }
        }
    }

    // ── Pull-down menu ─────────────────────────────────────────────
    SilicaPullDownMenu {
        // Larger touch area for mobile
        MenuItem {
            text: qsTr("Neu laden")
            onClicked: {
                webView.reload()
            }
        }
        MenuItem {
            text: qsTr("Im Browser öffnen")
            onClicked: Qt.openUrlExternally(whatsappUrl)
        }
        MenuItem {
            text: qsTr("Über")
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#111B21"
    }

    // ── Loading screen ─────────────────────────────────────────────
    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: "#111B21"
        z: 10
        visible: opacity > 0
        opacity: isLoading && !hasError ? 1.0 : 0.0

        Behavior on opacity { FadeAnimation { duration: 350 } }

        Column {
            anchors.centerIn: parent
            spacing: Theme.paddingLarge * 1.5

            // Animated logo circle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 96
                height: 96
                radius: 48
                color: "#25D366"

                SequentialAnimation on scale {
                    running: isLoading
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.08; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 800; easing.type: Easing.InOutSine }
                }

                Label {
                    anchors.centerIn: parent
                    text: "✓✓"
                    font.pixelSize: 34
                    color: "white"
                    font.bold: true
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "WhatsApp"
                font.pixelSize: Theme.fontSizeExtraLarge
                color: "#E9EDEF"
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Verbinde...")
                color: "#8696A0"
                font.pixelSize: Theme.fontSizeSmall
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: isLoading && !hasError
                size: BusyIndicatorSize.Medium
            }
        }
    }

    // ── Error screen ───────────────────────────────────────────────
    Rectangle {
        id: errorOverlay
        anchors.fill: parent
        color: "#111B21"
        z: 10
        visible: hasError

        Column {
            anchors.centerIn: parent
            spacing: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 4

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "⚠"
                font.pixelSize: 72
                color: "#FF6B6B"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Keine Verbindung")
                font.pixelSize: Theme.fontSizeLarge
                color: "#E9EDEF"
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: errorText !== ""
                    ? errorText
                    : qsTr("WhatsApp Web konnte nicht erreicht werden.\nBitte Internetverbindung prüfen.")
                color: "#8696A0"
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            // Mobile-friendly large button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.75
                height: Theme.itemSizeMedium
                radius: height / 2
                color: retryArea.pressed ? "#1DA851" : "#25D366"

                Behavior on color { ColorAnimation { duration: 100 } }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Erneut versuchen")
                    color: "white"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    id: retryArea
                    anchors.fill: parent
                    onClicked: {
                        hasError = false
                        isLoading = true
                        webView.url = whatsappUrl
                    }
                }
            }
        }
    }

    // ── WebView ────────────────────────────────────────────────────
    WebView {
        id: webView
        anchors.fill: parent

        // Mobile-optimized: enable viewport scaling
        settings.javaScriptEnabled:  true
        settings.localStorageEnabled: true

        url: whatsappUrl

        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                isLoading = true
                hasError  = false
                break

            case WebView.LoadSucceededStatus:
                isLoading = false
                hasError  = false
                webReady  = true
                injectTweaks()
                break

            case WebView.LoadFailedStatus:
                isLoading  = false
                hasError   = true
                errorText  = loadRequest.errorString
                break
            }
        }

        onTitleChanged: {
            appWindow.pageTitle = title

            // Parse "(3) WhatsApp" → unread = 3
            var match = title.match(/^\((\d+)\)/)
            var newCount = match ? parseInt(match[1]) : 0
            var prevCount = appWindow.unreadCount
            appWindow.unreadCount = newCount

            // Forward to daemon
            daemonDbus.call('UpdateUnreadCount', [newCount])

            // Send local notification if app is in background
            if (!appWindow.applicationActive && newCount > prevCount) {
                sendNotification(newCount, prevCount)
            }
        }

        function injectTweaks() {
            // 1. Override UA → Android Chrome
            runJavaScript(
                'Object.defineProperty(navigator,"userAgent",{get:function(){return "'
                + userAgent + '";}});'
            )

            // 2. Stub out Notification API (we handle it natively)
            runJavaScript('window.Notification=undefined;')

            // 3. Mobile viewport + smooth scroll
            runJavaScript(
                'var m=document.querySelector("meta[name=viewport]");'
                + 'if(!m){m=document.createElement("meta");m.name="viewport";document.head.appendChild(m);}'
                + 'm.content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no";'
                + 'document.body.style.overscrollBehavior="none";'
            )

            // 4. Hide WA "use on phone" banner & download-app prompts
            runJavaScript(
                '(function(){'
                + 'var s=document.createElement("style");'
                + 's.textContent='
                + '"[data-testid=\\"intro-md-beta-logo-dark\\"],'
                + '[data-testid=\\"intro-md-beta-logo-light\\"],'
                + '.landing-wrapper .landing-main { display:none!important; }'
                + '.app-wrapper-web { padding-bottom: 0!important; }"'
                + ';document.head.appendChild(s);'
                + '})()'
            )

            // 5. Larger touch targets for Sailfish finger size
            runJavaScript(
                '(function(){'
                + 'var s=document.createElement("style");'
                + 's.textContent="'
                + '* { -webkit-tap-highlight-color: rgba(37,211,102,0.2)!important; }'
                + '[data-testid] { min-height: 48px; }'
                + '";document.head.appendChild(s);'
                + '})()'
            )
        }
    }

    // ── Hardware back button ───────────────────────────────────────
    Keys.enabled: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back && webView.canGoBack) {
            webView.goBack()
            event.accepted = true
        }
    }
}
