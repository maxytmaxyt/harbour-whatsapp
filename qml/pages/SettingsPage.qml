import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: settingsPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Einstellungen") }

            // ── Datenschutz ────────────────────────────────────────
            SectionHeader { text: qsTr("Datenschutz") }

            TextSwitch {
                text:        qsTr("Privat-Modus")
                description: qsTr("Versteckt den Inhalt wenn die App in den Hintergrund wechselt — kein WA-Inhalt im App-Switcher oder Cover-Vorschau.")
                checked:     appWindow.privacyMode
                onCheckedChanged: appWindow.privacyMode = checked
            }

            // ── Anzeige ────────────────────────────────────────────
            SectionHeader { text: qsTr("Anzeige") }

            TextSwitch {
                text:        qsTr("Bildschirm anlassen")
                description: qsTr("Verhindert das automatische Sperren des Bildschirms solange die App offen ist.")
                checked:     appWindow.keepScreenOn
                onCheckedChanged: appWindow.keepScreenOn = checked
            }

            SectionHeader { text: qsTr("Schriftgröße") }

            Label {
                x:     Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text:  qsTr("Passt die Schriftgröße der WhatsApp-Oberfläche an.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }

            Slider {
                id: fontSlider
                width:        parent.width
                minimumValue: 12
                maximumValue: 24
                stepSize:     1
                value:        appWindow.fontSize
                label:        qsTr("Schriftgröße")
                valueText:    value + " px"
                onValueChanged: appWindow.fontSize = value
            }

            // Preview label that reflects the slider live
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Vorschau: Hallo Welt!")
                font.pixelSize: fontSlider.value * Theme.fontSizeSmall / 16
                color: Theme.primaryColor
                padding: Theme.paddingMedium
            }

            Item { height: Theme.paddingLarge * 2 }

            // ── Reset ──────────────────────────────────────────────
            SectionHeader { text: qsTr("Zurücksetzen") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Standardeinstellungen wiederherstellen")
                onClicked: {
                    appWindow.privacyMode  = false
                    appWindow.keepScreenOn = false
                    appWindow.fontSize     = 16
                }
            }

            Item { height: Theme.paddingLarge }
        }
    }
}