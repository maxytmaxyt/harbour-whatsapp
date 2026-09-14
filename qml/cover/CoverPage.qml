import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#111B21" }
            GradientStop { position: 1.0; color: "#1A2A35" }
        }
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Theme.paddingLarge * 2
        }
        spacing: Theme.paddingMedium

        // Logo with pulse when there are unread messages
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72; height: 72; radius: 36
            color: "#25D366"

            SequentialAnimation on scale {
                running: appWindow.unreadCount > 0
                loops:   Animation.Infinite
                NumberAnimation { to: 1.1;  duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
            }

            Label {
                anchors.centerIn: parent
                text: "✓✓"
                font.pixelSize: 26
                color: "white"
                font.bold: true
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WhatsApp"
            font.pixelSize: Theme.fontSizeMedium
            color: "#E9EDEF"
            font.bold: true
        }

        // Unread count badge – animates in/out
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: appWindow.unreadCount > 0
            width:   Math.max(40, unreadLabel.width + 20)
            height:  40
            radius:  20
            color:   "#25D366"

            scale: visible ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            Label {
                id: unreadLabel
                anchors.centerIn: parent
                text:  appWindow.unreadCount > 99 ? "99+" : appWindow.unreadCount.toString()
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: appWindow.unreadCount === 0
            text:    qsTr("Keine neuen Nachrichten")
            color:   "#8696A0"
            font.pixelSize: Theme.fontSizeTiny
        }
    }

    // ── Cover actions ──────────────────────────────────────────────
    // Action 1: Open app normally
    // Action 2: Reload – sets pendingReload flag; MainPage reloads on activation
    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-open"
            onTriggered: appWindow.activate()
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                appWindow.pendingReload = true
                appWindow.activate()
            }
        }
    }
}