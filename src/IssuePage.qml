import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import U1db 1.0 as U1db

Page {
    id: issuePage

    property string issueId: ''
    property string url: ''
    property string image: ''
    property string description: ''
    property var downloads: null

    head.actions: [
        Action {
            id: about
            iconName: 'info'
            text: i18n.tr('About')
            onTriggered: pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
        }
    ]

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

            UbuntuShape {
                Layout.preferredWidth: units.gu(30)
                Layout.preferredHeight: width * (3/4)
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                sourceFillMode: UbuntuShape.PreserveAspectCrop
                source: Image {
                    source: issuePage.image
                }
            }

            Label {
                Layout.fillWidth: true

                text: issuePage.description
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: issuePage.downloads

                delegate: ListItem {
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)

                        Label {
                            text: i18n.tr('Download: ') + model.lang + ' ' + i18n.tr('PDF')
                            Layout.fillWidth: true
                        }

                        Icon {
                            name: "next"
                            Layout.fillHeight: true
                        }
                    }

                    onClicked: {
                        pageStack.addPageToCurrentColumn(issuePage, Qt.resolvedUrl("DownloadPage.qml"), {
                            title: i18n.tr('Downloading: ') + issuePage.title,
                            issueId: issuePage.id,
                            url: model.link,
                            lang: model.lang
                        });
                    }
                }
            }
        }
    }
}
