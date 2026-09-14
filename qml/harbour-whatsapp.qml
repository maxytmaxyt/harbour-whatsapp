import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebView 1.1
import "pages"
import "cover"

ApplicationWindow {
    id: appWindow
    initialPage: mainPage
    cover: coverPage

    // Track unread count from cover
    property int unreadCount: 0
    property bool isConnected: true
    property string pageTitle: "WhatsApp"

    Component {
        id: mainPage
        MainPage {}
    }

    Component {
        id: coverPage
        CoverPage {}
    }
}
