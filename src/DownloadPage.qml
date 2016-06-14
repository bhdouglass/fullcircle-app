import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "index.js" as Index

Page {
    id: downloadPage

    property string issueId: ''
    property string url: ''
    property string lang: ''
    property string path: ''
    property bool downloading: true
    property var activeTransfer

    U1db.Database {
        id: u1db
        path: "fullcircle.bhdouglass.downloads"
    }

    Component.onCompleted: {
        readButton.visible = false;

        if (url) {
            var doc = u1db.getDoc(Index.urlToId(url));
            if (doc && doc.path) {
                console.log('found downloaded file in database');

                path = doc.path;
                downloading = false;
                readButton.visible = true;
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

            u1db.putDoc({
                path: path,
                url: url,
            }, Index.urlToId(url));
        }
    }

    Flickable {
        anchors.fill: parent
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
                onClicked: PopupUtils.open(openDialog, downloadPage, {'path': downloadPage.path});
            }
        }
    }

    Component {
        id: openDialog
        OpenDialog {}
    }
}
