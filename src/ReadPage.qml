import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db

import Poppler 1.0 as Poppler

Page {
    id: readPage

    property string path: ''

    anchors.fill: pageStack.parent

    header: PageHeader {
        id: header
        title: parent.title

        leadingActionBar.actions: [
            Action {
                iconName: 'back'
                text: i18n.tr('Back')
                onTriggered: readPage.destroy()
            }
        ]
    }

    Rectangle {
        anchors.fill: parent
        color: white

        //Based on code from the document viewer app: http://bazaar.launchpad.net/~ubuntu-docviewer-dev/ubuntu-docviewer-app/lo-viewer/view/head:/src/app/qml/pdfView/PdfView.qml
        ScrollView {
            anchors.fill: parent

            Poppler.VerticalView {
                id: pdfView

                anchors.fill: parent
                anchors.topMargin: readPage.header.height
                spacing: units.gu(2)

                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 1500 * units.gridUnit / 8
                maximumFlickVelocity: 2500 * units.gridUnit / 8

                contentWidth: parent.width * _zoomHelper.scale
                cacheBuffer: height * poppler.providersNumber * _zoomHelper.scale * 0.5
                interactive: !pinchy.pinch.active

                model: poppler
                delegate: Poppler.ViewDelegate {
                    Component.onDestruction: window.releaseResources()
                }

                PinchArea {
                    id: pinchy
                    anchors.fill: parent

                    pinch {
                        target: _zoomHelper
                        minimumScale: 1.0
                        maximumScale: 2.5
                    }

                    onPinchFinished: {
                        pdfView.returnToBounds();
                        window.releaseResources();
                    }
                }

                Item {
                    id: _zoomHelper
                }
            }
        }

        Poppler.Document {
            id: poppler

            property bool isLoading: true
            path: readPage.path

            onPagesLoaded: {
                isLoading = false;

                console.log('loaded');
            }
        }
    }
}
