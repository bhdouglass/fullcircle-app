import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import U1db 1.0 as U1db
import "utils.js" as Utils

Page {
    id: issueListPage
    title: i18n.tr('Full Circle Magazine')

    property bool loading: false
    property bool err: false
    property var issues: []

    header: PageHeader {
        id: header
        title: parent.title

        trailingActionBar.actions: [
            Action {
                iconName: 'info'
                text: i18n.tr('About')
                onTriggered: pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
            }
        ]
    }

    function refreshIssues() {
        var issues = [];
        var docs = issuesdb.listDocs();
        for (var index in docs) {
            var issue = issuesdb.getDoc(docs[index]);

            if (issue && issue.title) {
                issues.push(issue);
            }
        }

        issues.reverse();
        issueListPage.issues = issues;
    }

    function refresh() {
        issueListPage.loading = true;
        Utils.fetchIssues(function(err, issues) {
            if (err) {
                console.error('error: ' + err);
                issueListPage.err = true;
            }
            else {
                var ids = [];
                for (var index in issues) {
                    issuesdb.putDoc(issues[index], issues[index].id);
                    ids.push(issues[index].id);
                }

                //Remove unrecognized issues
                var docs = issuesdb.listDocs();
                for (var index in docs) {
                    if (ids.indexOf(docs[index]) == -1) {
                        issuesdb.deleteDoc(docs[index]);
                    }
                }

                refreshIssues();
                issueListPage.err = false;
            }

            issueListPage.loading = false;
        });
    }

    Component.onCompleted: {
        refreshIssues(); //Prepopulate any existing data before the network request comes back
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
                model: issues

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
                                source: Qt.resolvedUrl(modelData.image)
                            }
                        }

                        Label {
                            text: modelData.title
                            Layout.fillWidth: true
                        }
                    }

                    onClicked: {
                        pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("IssuePage.qml"), {
                            title: modelData.title,
                            issueId: modelData.id,
                            url: modelData.url,
                            image: modelData.image,
                            description: modelData.description,
                            downloads: modelData.downloads,
                        });
                    }
                }
            }
        }
    }
}
