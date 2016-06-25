import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "utils.js" as Utils

Page {
    id: downloadPage

    property string issueId: ''
    property string issueTitle: ''
    property string url: ''
    property string lang: ''
    property string path: ''
    property bool downloading: true
    property var activeTransfer

    header: PageHeader {
        id: header
        title: parent.title
    }

    U1db.Database {
        id: u1db
        path: "fullcircle.bhdouglass.downloads"
    }

    Component.onCompleted: {
        readButton.visible = false;
        openButton.visible = false;

        if (url) {
            var doc = u1db.getDoc(Utils.urlToId(url));
            if (doc && doc.path) {
                console.log('found downloaded file in database');

                path = doc.path;
                downloading = false;
                readButton.visible = true;
                openButton.visible = true;
            }
            else {
                console.log('going to download file');

                downloading = true;
                download.download(url);
            }
        }
    }

    SingleDownload {
        id: download

        autoStart: true

        onFinished: {
            downloadPage.path = path;
            readButton.visible = true;
            openButton.visible = true;

            u1db.putDoc({
                path: path,
                url: url,
            }, Utils.urlToId(url));
        }
    }

    Flickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: contentColumn.height + units.gu(4)

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left;
                top: parent.top;
                right: parent.right;
                margins: units.gu(2);
            }
            spacing: units.gu(2)

            Label {
                text: downloadPage.lang + ' ' + i18n.tr('PDF')
            }

            ProgressBar {
                Layout.fillWidth: true

                minimumValue: 0
                maximumValue: 100
                value: downloading ? download.progress : 100
            }

            Button {
                id: readButton
                visible: false

                Layout.fillWidth: true

                text: i18n.tr('Read')
                color: UbuntuColors.orange
                //onClicked: pageStack.addPageToCurrentColumn(downloadPage, Qt.resolvedUrl('ReadPage.qml'), {
                onClicked: PopupUtils.open(Qt.resolvedUrl('ReadPage.qml'), downloadPage, {
                    path: downloadPage.path,
                    title: i18n.tr('Reading: ') + downloadPage.issueTitle,
                })
            }

            Button {
                id: openButton
                visible: false

                Layout.fillWidth: true

                text: i18n.tr('Open Externally')
                //color: UbuntuColors.orange
                onClicked: PopupUtils.open(openDialog, downloadPage, {'path': downloadPage.path});
            }
        }
    }

    Component {
        id: openDialog
        OpenDialog {}
    }
}
