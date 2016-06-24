import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import U1db 1.0 as U1db
import "utils.js" as Utils

Page {
    id: issueListPage
    title: i18n.tr('Full Circle Magazine')

    property bool loading: false

    header: PageHeader {
        id: header
        title: parent.title

        trailingActionBar.actions: [
            Action {
                iconName: 'info'
                text: i18n.tr('About')
                onTriggered: pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl('AboutPage.qml'))
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
        issueList.issues = issues;
    }

    function refresh() {
        issueListPage.loading = true;
        Utils.fetchIssues(function(err, issues) {
            if (err) {
                console.error('error: ' + err);
                issueList.err = true;
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
                issueList.err = false;
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

    IssueList {
        id: issueList

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onRefresh: refresh();
    }
}
