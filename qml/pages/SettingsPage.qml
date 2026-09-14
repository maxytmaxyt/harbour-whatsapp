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

            PageHeader { title: qsTr("Settings") }

            // ── Privacy ────────────────────────────────────────────
            SectionHeader { text: qsTr("Privacy") }

            TextSwitch {
                text:        qsTr("Privacy mode")
                description: qsTr("Hides content when the app goes to the background — no WhatsApp content in the app switcher or cover preview.")
                checked:     appWindow.privacyMode
                onCheckedChanged: appWindow.privacyMode = checked
            }

            // ── Display ────────────────────────────────────────────
            SectionHeader { text: qsTr("Display") }

            TextSwitch {
                text:        qsTr("Keep screen on")
                description: qsTr("Prevents the screen from locking automatically while the app is open.")
                checked:     appWindow.keepScreenOn
                onCheckedChanged: appWindow.keepScreenOn = checked
            }

            SectionHeader { text: qsTr("Font size") }

            Label {
                x:     Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text:  qsTr("Adjusts the font size of the WhatsApp interface.")
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
                label:        qsTr("Font size")
                valueText:    value + " px"
                onValueChanged: appWindow.fontSize = value
            }

            // Preview label that reflects the slider live
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Preview: Hello World!")
                font.pixelSize: fontSlider.value * Theme.fontSizeSmall / 16
                color: Theme.primaryColor
                padding: Theme.paddingMedium
            }

            Item { height: Theme.paddingLarge * 2 }

            // ── Reset ──────────────────────────────────────────────
            SectionHeader { text: qsTr("Reset") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Restore defaults")
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
