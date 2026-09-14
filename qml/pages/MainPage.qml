import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1

Page {
    id: page
    allowedOrientations: Orientation.All

    // WhatsApp Web User-Agent (Android Chrome - needed for WA Web to work)
    readonly property string userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
    readonly property string whatsappUrl: "https://web.whatsapp.com"

    property bool isLoading: true
    property bool hasError: false
    property string errorText: ""

    // Pull-down menu
    SilicaPullDownMenu {
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

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#111B21"  // WhatsApp dark background
    }

    // Loading indicator overlay
    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: "#111B21"
        z: 10
        visible: isLoading && !hasError
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            FadeAnimation { duration: 400 }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.paddingLarge

            // WhatsApp logo placeholder (green circle)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 100
                radius: 50
                color: "#25D366"

                Text {
                    anchors.centerIn: parent
                    text: "✓✓"
                    font.pixelSize: 36
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

    // Error state
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
                font.pixelSize: 64
                color: "#FF6B6B"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Connection failed")
                font.pixelSize: Theme.fontSizeLarge
                color: "#E9EDEF"
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: errorText || qsTr("Could not reach WhatsApp Web.\nPlease check your internet connection.")
                color: "#8696A0"
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Try Again")
                onClicked: {
                    hasError = false
                    isLoading = true
                    webView.url = whatsappUrl
                }
            }
        }
    }

    // The actual WebView
    WebView {
        id: webView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        settings.javaScriptEnabled: true
        settings.localStorageEnabled: true
        // Custom Android UA so WhatsApp Web loads properly
        // Note: QtWebView doesn't expose userAgent directly,
        // we inject it via JS after load
        url: whatsappUrl

        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                isLoading = true
                hasError = false
                break

            case WebView.LoadSucceededStatus:
                isLoading = false
                hasError = false
                // Inject JS tweaks for Sailfish compatibility
                injectSailfishTweaks()
                break

            case WebView.LoadFailedStatus:
                isLoading = false
                hasError = true
                errorText = loadRequest.errorString
                break
            }
        }

        onTitleChanged: {
            appWindow.pageTitle = title
            // Parse unread count from title e.g. "(3) WhatsApp"
            var match = title.match(/^\((\d+)\)/)
            if (match) {
                appWindow.unreadCount = parseInt(match[1])
            } else {
                appWindow.unreadCount = 0
            }
        }

        function injectSailfishTweaks() {
            // Override UA for proper WA Web experience
            var jsUa = 'Object.defineProperty(navigator, "userAgent", { get: function() { return "' + userAgent + '"; } });'
            // Disable notifications permission request (no native support)
            var jsNotif = 'Notification = undefined;'
            // Make scrolling feel more native
            var jsScroll = 'document.body.style.overscrollBehavior = "none";'
            // Hide "Use WhatsApp on phone" banners
            var jsHideBanner = 'var style = document.createElement("style"); style.textContent = ".x78zum5.xdt5ytf { display: none !important; } "; document.head.appendChild(style);'

            runJavaScript(jsUa)
            runJavaScript(jsNotif)
            runJavaScript(jsScroll)
            runJavaScript(jsHideBanner)
        }
    }

    // Navigation back gesture support
    onStatusChanged: {
        if (status === PageStatus.Active && webView.canGoBack) {
            // Handled by backNavigation
        }
    }

    // Handle hardware back button
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            if (webView.canGoBack) {
                webView.goBack()
                event.accepted = true
            }
        }
    }
    Keys.enabled: true
}
