import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("About") }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 120; height: 120; radius: 60
                color: "#25D366"
                Label {
                    anchors.centerIn: parent
                    text: "✓✓"
                    font.pixelSize: 48
                    color: "white"
                    font.bold: true
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("WhatsApp for Sailfish OS")
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Version 1.2.0"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("About this app") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("This app wraps WhatsApp Web (web.whatsapp.com) in a native Sailfish OS interface.\n\nWhatsApp is a product of Meta Platforms, Inc. This app is not affiliated with or endorsed by WhatsApp or Meta.")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Features") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("• Native Sailfish Silica UI\n• Cover with unread badge\n• Background notifications\n• Privacy mode (hide content in background)\n• Keep screen on\n• Adjustable font size\n• Left-edge swipe to go back\n• Systemd daemon for notifications")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Requirements") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("• Active internet connection\n• WhatsApp account on your phone\n• Scan QR code on first launch")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Source Code") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: "github.com/maxytmaxyt/harbour-whatsapp"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally("https://github.com/maxytmaxyt/harbour-whatsapp")
                }
            }

            Item { height: Theme.paddingLarge }
        }
    }
}
