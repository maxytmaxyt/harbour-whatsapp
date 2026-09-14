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

            PageHeader { title: qsTr("Über") }

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
                text: "WhatsApp für Sailfish OS"
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

            SectionHeader { text: qsTr("Über diese App") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Diese App bindet WhatsApp Web (web.whatsapp.com) in eine native Sailfish-OS-Oberfläche ein.\n\nWhatsApp ist ein Produkt von Meta Platforms, Inc. Diese App ist nicht mit WhatsApp oder Meta verbunden oder von ihnen genehmigt.")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Features") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("• Native Sailfish Silica UI\n• Cover mit Ungelesen-Badge\n• Hintergrund-Benachrichtigungen\n• Privat-Modus (Inhalt im Hintergrund verbergen)\n• Bildschirm anlassen\n• Schriftgröße anpassbar\n• Linke-Rand-Wischgeste zurück\n• Systemd-Daemon für Benachrichtigungen")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Voraussetzungen") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("• Aktive Internetverbindung\n• WhatsApp-Konto auf deinem Handy\n• QR-Code beim ersten Start scannen")
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Quellcode") }

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