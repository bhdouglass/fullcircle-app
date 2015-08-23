import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "moment.js" as Moment

Page {
    id: root

    property string url
    property string name
    property string path
    property bool downloading: true
    property var activeTransfer

    title: i18n.tr('Download')

    U1db.Database {
        id: u1db
        path: "fullcircle.bhdouglass.downloads"
    }

    onUrlChanged: {
        open.visible = false;

        if (url) {
            var doc = u1db.getDoc(urlToId(url));
            if (doc && doc.path) {
                console.log('found downloaded file in database');

                path = doc.path;
                downloading = false;
                open.visible = true;
            }
            else {
                console.log('going to download file');

                downloading = true;
                download.download(url);
            }
        }
    }

    function urlToId(url) {
        return url.replace('http://', '').replace('https://', '').replace(/\./g, '_').replace(/\//g, '_');
    }

    SingleDownload {
        id: download

        autoStart: true

        onFinished: {
            root.path = path;
            open.visible = true;

            var now = Moment.moment();
            u1db.putDoc({
                path: path,
                url: url,
                fetchTime: now.valueOf(),
            }, urlToId(url));
        }
    }

    Label {
        id: label

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        text: i18n.tr('Downloading: ') + name
    }

    ProgressBar {
        id: progress

        minimumValue: 0
        maximumValue: 100
        value: downloading ? download.progress : 100

        anchors {
            left: parent.left
            right: parent.right
            top: label.bottom

            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
    }

    Button {
        id: open
        visible: false

        anchors {
            left: parent.left
            right: parent.right
            top: progress.bottom

            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        text: i18n.tr('Open')
        color: UbuntuColors.orange
        onClicked: {
            PopupUtils.open(openDialog, root, {'path': root.path});
        }
    }

    Component {
        id: openDialog
        OpenDialog {}
    }
}
