import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1
import Nemo.DBus 2.0
import Nemo.Notifications 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    readonly property string userAgent:    "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
    readonly property string whatsappUrl:  "https://web.whatsapp.com"

    property bool isLoading: true
    property bool hasError:  false
    property string errorText: ""
    property bool webReady:  false

    // ── DBus: app daemon ───────────────────────────────────────────
    DBusInterface {
        id: daemonDbus
        service: 'net.maxyt.WhatsApp'
        path:    '/net/maxyt/WhatsApp'
        iface:   'net.maxyt.WhatsApp'
        bus:     DBus.SessionBus
        Component.onCompleted: call('SetAppActive', [true])
    }

    // ── DBus: MCE – prevent screen blanking ───────────────────────
    DBusInterface {
        id: mceDbus
        service: 'com.nokia.mce'
        path:    '/com/nokia/mce/request'
        iface:   'com.nokia.mce.request'
        bus:     DBus.SystemBus
    }

    // Calls MCE every 25 s while keepScreenOn is active and app is in foreground
    Timer {
        id: keepScreenTimer
        interval: 25000
        repeat:   true
        running:  appWindow.keepScreenOn && appWindow.applicationActive
        onTriggered: mceDbus.call('req_display_blanking_pause', [])
        onRunningChanged: {
            if (running) mceDbus.call('req_display_blanking_pause', [])
        }
    }

    // ── Sailfish notification ──────────────────────────────────────
    Notification {
        id: waNotification
        appName:  "WhatsApp"
        appIcon:  "harbour-whatsapp"
        category: "x-nemo.messaging.im"
        remoteActions: [{
            "name":        "default",
            "displayName": "Open",
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
        waNotification.summary  = "WhatsApp"
        waNotification.body     = diff === 1
            ? qsTr("You have 1 new message")
            : qsTr("You have %1 new messages").arg(diff)
        waNotification.itemCount = unread
        waNotification.publish()
    }

    // ── App lifecycle ──────────────────────────────────────────────
    Connections {
        target: appWindow
        onApplicationActiveChanged: {
            if (appWindow.applicationActive) {
                daemonDbus.call('SetAppActive', [true])
                waNotification.close()
                // Handle cover reload action
                if (appWindow.pendingReload && webReady) {
                    webView.reload()
                    appWindow.pendingReload = false
                }
            } else {
                daemonDbus.call('SetAppActive', [false])
            }
        }
        // Inject font size whenever setting changes
        onFontSizeChanged: {
            if (webReady) injectFontSize()
        }
    }

    // ── Pull-down menu ─────────────────────────────────────────────
    SilicaPullDownMenu {
        MenuItem {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
        }
        MenuItem {
            text: qsTr("Reload")
            onClicked: webView.reload()
        }
        MenuItem {
            text: qsTr("Open in Browser")
            onClicked: Qt.openUrlExternally(whatsappUrl)
        }
        MenuItem {
            text: qsTr("About")
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#111B21"
    }

    // ── Loading overlay ────────────────────────────────────────────
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

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 96; height: 96; radius: 48
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
                text: qsTr("Connecting...")
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

    // ── Error overlay ──────────────────────────────────────────────
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
                text: qsTr("No connection")
                font.pixelSize: Theme.fontSizeLarge
                color: "#E9EDEF"
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: errorText !== ""
                    ? errorText
                    : qsTr("Could not reach WhatsApp Web.\nPlease check your internet connection.")
                color: "#8696A0"
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.75
                height: Theme.itemSizeMedium
                radius: height / 2
                color: retryArea.pressed ? "#1DA851" : "#25D366"
                Behavior on color { ColorAnimation { duration: 100 } }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Try again")
                    color: "white"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeMedium
                }
                MouseArea {
                    id: retryArea
                    anchors.fill: parent
                    onClicked: {
                        hasError  = false
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
        settings.javaScriptEnabled:   true
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
                injectFontSize()
                break
            case WebView.LoadFailedStatus:
                isLoading = false
                hasError  = true
                errorText = loadRequest.errorString
                break
            }
        }

        onTitleChanged: {
            appWindow.pageTitle = title
            var match     = title.match(/^\((\d+)\)/)
            var newCount  = match ? parseInt(match[1]) : 0
            var prevCount = appWindow.unreadCount
            appWindow.unreadCount = newCount
            daemonDbus.call('UpdateUnreadCount', [newCount])
            if (!appWindow.applicationActive && newCount > prevCount) {
                sendNotification(newCount, prevCount)
            }
        }

        function injectTweaks() {
            // 1. Android Chrome User-Agent
            runJavaScript(
                'Object.defineProperty(navigator,"userAgent",{get:function(){return "'
                + userAgent + '";}});'
            )
            // 2. Disable web Notification API (we handle it natively)
            runJavaScript('window.Notification=undefined;')
            // 3. Mobile viewport
            runJavaScript(
                'var m=document.querySelector("meta[name=viewport]");'
                + 'if(!m){m=document.createElement("meta");m.name="viewport";document.head.appendChild(m);}'
                + 'm.content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no";'
                + 'document.body.style.overscrollBehavior="none";'
            )
            // 4. Hide WA "use on phone" / download-app banners
            runJavaScript(
                '(function(){'
                + 'var s=document.createElement("style");'
                + 's.textContent="'
                + '[data-testid=\\"intro-md-beta-logo-dark\\"],'
                + '[data-testid=\\"intro-md-beta-logo-light\\"],'
                + '.landing-wrapper .landing-main{display:none!important;}'
                + '.app-wrapper-web{padding-bottom:0!important;}";'
                + 'document.head.appendChild(s);'
                + '})()'
            )
            // 5. Larger touch targets for Sailfish finger size
            runJavaScript(
                '(function(){'
                + 'var s=document.createElement("style");'
                + 's.textContent="'
                + '*{-webkit-tap-highlight-color:rgba(37,211,102,0.2)!important;}'
                + '[data-testid]{min-height:48px;}";'
                + 'document.head.appendChild(s);'
                + '})()'
            )
            // 6. Smooth scrolling everywhere
            runJavaScript(
                '(function(){'
                + 'var s=document.createElement("style");'
                + 's.textContent="html{scroll-behavior:smooth;}'
                + '*{-webkit-overflow-scrolling:touch;}";'
                + 'document.head.appendChild(s);'
                + '})()'
            )
        }

        function injectFontSize() {
            var zoom = appWindow.fontSize / 16.0
            runJavaScript(
                'document.documentElement.style.fontSize="' + appWindow.fontSize + 'px";'
            )
        }
    }

    // ── Left-edge swipe zone (Sailfish-style back gesture) ─────────
    // Thin transparent strip on the left — swipe right to go back
    MouseArea {
        id: leftEdgeSwipe
        width:  Theme.paddingLarge * 1.5   // ~30 px
        anchors {
            left:   parent.left
            top:    parent.top
            bottom: parent.bottom
        }
        z: 50   // above WebView, below overlays
        enabled: webView.canGoBack

        property real startX: 0

        onPressed:  startX = mouseX
        onReleased: {
            var dx = mouseX - startX
            if (dx > Theme.itemSizeSmall && webView.canGoBack) {
                webView.goBack()
            }
        }

        // Visual hint: subtle green glow when active
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#25D366"
            border.width: leftEdgeSwipe.pressed ? 2 : 0
            opacity: 0.6
            Behavior on border.width { NumberAnimation { duration: 80 } }
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

    // ── Privacy screen ─────────────────────────────────────────────
    // Shown immediately when app leaves foreground and privacy mode is on.
    // Prevents WA content from appearing in the cover thumbnail / task switcher.
    Rectangle {
        id: privacyOverlay
        anchors.fill: parent
        z: 200
        color: "#111B21"
        visible: !appWindow.applicationActive && appWindow.privacyMode

        Column {
            anchors.centerIn: parent
            spacing: Theme.paddingLarge

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 88; height: 88; radius: 44
                color: "#1A2A35"
                border.color: "#25D366"
                border.width: 2

                Label {
                    anchors.centerIn: parent
                    text: "🔒"
                    font.pixelSize: 36
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "WhatsApp"
                color: "#E9EDEF"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Content hidden")
                color: "#8696A0"
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}