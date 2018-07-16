import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import U1db 1.0 as U1db

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'fullcircle.bhdouglass'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property var favorites: []

    U1db.Database {
        id: favoritesdb
        path: 'fullcircle.bhdouglass.favorites.v1'
    }

    U1db.Database {
        id: issuesdb
        path: 'fullcircle.bhdouglass.issues.v2'
    }

    AdaptivePageLayout {
        id: pageStack
        anchors.fill: parent
        primaryPageSource: Qt.resolvedUrl('IssueListPage.qml')
    }

    BottomEdge {
        id: bottomEdge
        height: parent.height - units.gu(20)

        contentComponent: Rectangle {
            id: bottomEdgeComponent

            PageHeader {
                id: header
                title: i18n.tr('Favorites')
            }

            width: bottomEdge.width
            height: bottomEdge.height

            IssueList {
                id: issueList
                issues: favorites

                visible: issueList.issues.length > 0

                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                onRefresh: refresh();
                onIssueClicked: bottomEdge.collapse();
            }

            Flickable {
                visible: issueList.issues.length === 0

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
                        topMargin: units.gu(1)
                    }
                    spacing: units.gu(1)

                    Label {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        horizontalAlignment: Label.AlignHCenter

                        text: i18n.tr('No favorites yet!\nTap the star icon to save your favorite issues here.')
                    }
                }
            }
        }

        onStatusChanged: {
            if (status == BottomEdge.Revealed && dragDirection == BottomEdge.Upwards) {
                //The user is dragging the bottom edge up, populate the favorites

                var favorites = [];
                var docs = favoritesdb.listDocs();
                for (var index in docs) {
                    var favorite = favoritesdb.getDoc(docs[index]);
                    if (favorite.favorite) {
                        var issue = issuesdb.getDoc(docs[index]);

                        if (issue && issue.title) {
                            favorites.push(issue);
                        }
                    }
                }

                favorites.reverse();
                root.favorites = favorites;
            }
        }
    }
}
