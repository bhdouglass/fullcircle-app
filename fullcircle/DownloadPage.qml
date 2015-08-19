import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

Page {
    id: root

    property string url: ""
    property string name: ""
    property string downloadId: ""
    property var activeTransfer

    title: i18n.tr("Download")

    onUrlChanged: {
        if (url) {
            download.download(url);
        }
    }

    SingleDownload {
        id: download

        autoStart: true

        onDownloadIdChanged: {
            console.log('download id changed');
            console.log(download.downloadId);

            root.downloadId = downloadId;
            console.log(root.downloadId);
            PopupUtils.open(openDialog, root, {/*"contentType": ContentType.Documents, */"downloadId": root.downloadId});
        }

        /*onFinished: {
            console.log(path);
            console.log(download.isCompleted)
            console.log('download id ' + download.downloadId);
            console.log(download.downloadId);
        }*/
    }

    Label {
        id: label

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        text: "Downloading: " + name
    }

    ProgressBar {
        id: progress

        minimumValue: 0
        maximumValue: 100
        value: download.progress

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
        //visible: download.isCompleted

        anchors {
            left: parent.left
            right: parent.right
            top: progress.bottom

            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        text: i18n.tr("Open")
        //onClicked: Qt.openUrlExternally(url)
        onClicked: {
            console.log('open');
            console.log(root.downloadId);
            PopupUtils.open(openDialog, root, {/*"contentType": ContentType.Documents, */"downloadId": root.downloadId});
        }
    }

    Component {
        id: openDialog
        OpenDialog {}
    }
}
