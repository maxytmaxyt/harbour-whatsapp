#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtWebView/QtWebView>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QGuiApplication>

int main(int argc, char *argv[])
{
    QtWebView::initialize();

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-whatsapp");
    app->setApplicationVersion("1.1.0");
    app->setOrganizationName("net.maxyt");

    // Try to start the daemon via DBus activation (no-op if already running)
    QDBusConnection session = QDBusConnection::sessionBus();
    if (session.isConnected()) {
        QDBusInterface daemon(
            "net.maxyt.WhatsApp",
            "/net/maxyt/WhatsApp",
            "net.maxyt.WhatsApp",
            session
        );
        // Ping – if not running, DBus activation will start it
        daemon.call(QDBus::NoBlock, "GetUnreadCount");
    }

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();

    return app->exec();
}
