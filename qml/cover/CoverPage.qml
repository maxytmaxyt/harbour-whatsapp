import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    // WhatsApp green gradient background
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

        // Icon
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 64
            height: 64
            radius: 32
            color: "#25D366"

            Text {
                anchors.centerIn: parent
                text: "✓✓"
                font.pixelSize: 24
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

        // Unread badge
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: appWindow.unreadCount > 0
            width: Math.max(32, unreadLabel.width + 16)
            height: 32
            radius: 16
            color: "#25D366"

            Label {
                id: unreadLabel
                anchors.centerIn: parent
                text: appWindow.unreadCount > 99 ? "99+" : appWindow.unreadCount.toString()
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: appWindow.unreadCount === 0
            text: qsTr("No new messages")
            color: "#8696A0"
            font.pixelSize: Theme.fontSizeTiny
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                // Bring app to front and reload
                appWindow.activate()
            }
        }
    }
}
