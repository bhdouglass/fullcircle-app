import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import U1db 1.0 as U1db

Page {
    id: root

    property string img: ''
    property string link: ''
    property string issueId: ''
    property string description: ''
    property bool err: false
    signal download(string name, string url)

    U1db.Database {
        id: issuesdb
        path: 'fullcircle.bhdouglass.issues.v2'
    }

    onIssueIdChanged: {
        var issue = issuesdb.getDoc(root.issueId);
        root.title = issue.title;
        root.img = issue.image;
        root.description = issue.description;

        downloadsModel.clear();
        if (issue.downloads) {
            for (var index in issue.downloads) {
                downloadsModel.append(issue.downloads[index]);
            }
        }
    }

    Rectangle {
        id: container

        height: childrenRect.height
        color: 'transparent'

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: units.gu(1)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        UbuntuShape {
            id: image

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            width: parent.width * (3/4)
            height: width / 2

            sourceFillMode: UbuntuShape.PreserveAspectCrop
            source: Image {
                source: root.img
            }
        }

        ActivityIndicator {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            running: !description && !root.err
        }

        Label {
            id: errorLabel
            visible: root.err
            anchors {
                top: image.bottom
                topMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }

            text: i18n.tr('An error has occurred fetching data')
        }

        Button {
            visible: root.err
            anchors {
                top: errorLabel.bottom
                topMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }

            text: i18n.tr('Tap to retry')
            color: UbuntuColors.orange
            onClicked: {
                root.err = false;
                downloadsModel.clear();
                description = ''
                updateDatabase();
            }
        }

        Flickable {
            id: labelFlick
            visible: !root.err

            anchors {
                top: image.bottom
                topMargin: units.gu(2)
            }

            width: parent.width
            height: root.height / 2
            contentWidth: parent.width
            contentHeight: label.height

            flickableDirection: Flickable.VerticalFlick
            clip: true

            Label {
                id: label

                width: parent.width
                text: description
                wrapMode: Text.WordWrap
            }
        }
    }

    ListModel {
        id: downloadsModel
    }

    ListView {
        visible: !root.err
        width: parent.width
        anchors {
            top: container.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }

        model: downloadsModel
        delegate: ListItem.Standard {
            text: i18n.tr('Download: ') + model.lang + ' ' + i18n.tr('PDF')
            progression: true
            onClicked: root.download(root.title + ' (' + model.lang + ' ' + i18n.tr('PDF') + ')', model.link)
        }
    }
}
