import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import U1db 1.0 as U1db
import "index.js" as Index

Page {
    id: issueListPage
    title: i18n.tr('Full Circle Magazine')

    property bool loading: false
    property bool err: false

    head.actions: [
        Action {
            id: about
            iconName: 'info'
            text: i18n.tr('About')
            onTriggered: pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
        }
    ]

    function refresh() {
        issueListPage.loading = true;
        Index.refreshIssues(issueListModel, issuesdb, function(err) {
            issueListPage.loading = false;
            if (err) {
                issueListPage.err = true;
            }
            else {
                issueListPage.err = false;
            }
        });
    }

    Component.onCompleted: {
        refresh();
    }

    /*U1db.Database {
        id: metadatadb
        path: 'fullcircle.bhdouglass.metadata.v3'
    }*/

    U1db.Database {
        id: issuesdb
        path: 'fullcircle.bhdouglass.issues.v2'
    }

    ListModel {
        id: issueListModel
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
                topMargin: units.gu(1)
            }
            spacing: units.gu(1)

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                visible: issueListPage.err && issueListModel.count === 0
                text: i18n.tr('Unable to load issue list at this time')
            }

            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                visible: issueListPage.err && issueListModel.count === 0
                text: i18n.tr('Retry')
                color: UbuntuColors.orange

                onClicked: refresh()
            }

            Repeater {
                model: issueListModel

                delegate: ListItem {
                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: units.gu(1)
                            rightMargin: units.gu(1)
                            bottomMargin: units.gu(1)
                        }

                        UbuntuShape {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height

                            sourceFillMode: UbuntuShape.PreserveAspectCrop
                            source: Image {
                                source: Qt.resolvedUrl(model.image)
                            }
                        }

                        Label {
                            text: model.title
                            Layout.fillWidth: true
                        }
                    }

                    onClicked: {
                        pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("IssuePage.qml"), {
                            title: model.title,
                            issueId: model.id,
                            url: model.url,
                            image: model.image,
                            description: model.description,
                            downloads: model.downloads,
                        });
                    }
                }
            }
        }
    }
}
