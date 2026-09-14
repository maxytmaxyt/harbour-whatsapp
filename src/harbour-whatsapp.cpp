#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtWebView/QtWebView>

int main(int argc, char *argv[])
{
    // Initialize QtWebView before QGuiApplication
    QtWebView::initialize();

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    view->setSource(SailfishApp::pathToMainQml());
    view->show();

    return app->exec();
}
