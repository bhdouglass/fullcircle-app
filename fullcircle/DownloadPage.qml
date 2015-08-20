import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

Page {
    id: root

    property string url: ""
    property string name: ""
    property string path: ""
    property var activeTransfer

    title: i18n.tr("Download")

    onUrlChanged: {
        open.visible = false;

        if (url) {
            download.download(url);
        }
    }

    SingleDownload {
        id: download

        autoStart: true

        onFinished: {
            root.path = path;
            open.visible = true
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

        text: i18n.tr("Open")
        onClicked: {
            PopupUtils.open(openDialog, root, {"path": root.path});
        }
    }

    Component {
        id: openDialog
        OpenDialog {}
    }
}
