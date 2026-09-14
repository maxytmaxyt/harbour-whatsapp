import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1
import org.nemomobile.notifications 1.0
import Qt.labs.settings 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: appWindow
    initialPage: mainPage
    cover: coverPage

    // ── Persisted settings ─────────────────────────────────────────
    Settings {
        id: appSettings
        property bool privacyMode:   false
        property bool keepScreenOn:  false
        property int  fontSize:      16
    }

    // ── Runtime state ──────────────────────────────────────────────
    property int    unreadCount:      0
    property bool   isConnected:      true
    property string pageTitle:        "WhatsApp"
    property bool   daemonAvailable:  false
    property bool   pendingReload:    false   // set by cover action

    // Settings aliases (bound to persisted Settings)
    property bool   privacyMode:    appSettings.privacyMode
    property bool   keepScreenOn:   appSettings.keepScreenOn
    property int    fontSize:       appSettings.fontSize

    onPrivacyModeChanged:  appSettings.privacyMode  = privacyMode
    onKeepScreenOnChanged: appSettings.keepScreenOn = keepScreenOn
    onFontSizeChanged:     appSettings.fontSize     = fontSize

    // ── DBus poll heartbeat ────────────────────────────────────────
    Timer {
        id: daemonPollTimer
        interval: 30000
        running: true
        repeat: true
        onTriggered: { /* WebView title drives unreadCount live */ }
    }

    // Called by MainPage when WebView title changes
    function onUnreadChanged(count) {
        unreadCount = count
    }

    // Reset badge briefly after app is foregrounded
    onApplicationActiveChanged: {
        if (applicationActive) {
            resetBadgeTimer.start()
        }
    }

    Timer {
        id: resetBadgeTimer
        interval: 2000
        repeat: false
        onTriggered: { /* WebView title keeps count current */ }
    }

    Component { id: mainPage; MainPage {} }
    Component { id: coverPage; CoverPage {} }
}