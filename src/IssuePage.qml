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
    property bool favorite: false

    header: PageHeader {
        id: header
        title: parent.title

        trailingActionBar.actions: [
            Action {
                iconName: issuePage.favorite ? 'starred' : 'non-starred'
                text: issuePage.favorite ? i18n.tr('Unfavorite') : i18n.tr('Mark as Favorite')
                onTriggered: {
                    issuePage.favorite = !issuePage.favorite;
                    favoritesdb.putDoc({favorite: issuePage.favorite}, issuePage.issueId);
                }
            }
        ]
    }

    U1db.Database {
        id: favoritesdb
        path: 'fullcircle.bhdouglass.favorites.v1'
    }

    Component.onCompleted: {
        var doc = favoritesdb.getDoc(issuePage.issueId);
        if (doc && doc.favorite !== undefined) {
            issuePage.favorite = doc.favorite;
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
                            text: i18n.tr('Download: ') + modelData.lang + ' ' + i18n.tr('PDF')
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
                            issueId: issuePage.issueId,
                            issueTitle: issuePage.title,
                            url: modelData.link,
                            lang: modelData.lang
                        });
                    }
                }
            }
        }
    }
}
