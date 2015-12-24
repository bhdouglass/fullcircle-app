import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import U1db 1.0 as U1db
import "bundle.js" as Bundle

Page {
    id: root
    title: i18n.tr('Full Circle Magazine')

    property bool err: false
    signal openIssue(string issueId)

    U1db.Database {
        id: metadatadb
        path: 'fullcircle.bhdouglass.metadata.v2'
    }

    U1db.Database {
        id: issuesdb
        path: 'fullcircle.bhdouglass.issues.v2'
    }

    Timer {
        id: timer
        property var callback: function() {}
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            timer.callback();
        }
    }

    Component.onCompleted: {
        Bundle.setupTimeout(timer);

        var lastChecked = metadatadb.getDoc('lastChecked');
        var check = true;
        if (lastChecked) {
            var now = Bundle.modules.moment();
            lastChecked = Bundle.modules.moment(lastChecked);
            if (now.diff(lastChecked, 'days') === 0) {
                check = false;
            }
        }

        updateModel();
        if (check) {
            Bundle.modules.fetchIssues(function(err, issues, lastChecked) {
                if (err) {
                    if (!lastChecked) {
                        root.err = true;
                    }
                }
                else {
                    metadatadb.putDoc(lastChecked, 'lastChecked');
                    for (var index in issues) {
                        issuesdb.putDoc(issues[index], issues[index].id);
                    }

                    updateModel();
                }
            });
        }
    }

    function updateModel() {
        var issues = [];
        var docs = issuesdb.listDocs();
        for (var index in docs) {
            issues.push(issuesdb.getDoc(docs[index]));
        }

        issues.reverse();
        issueListModel.clear();
        for (var index in issues) {
            issueListModel.append(issues[index]);
        }
    }

    ListModel {
        id: issueListModel
    }

    Label {
        id: errorLabel
        visible: root.err
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
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
            issueListModel.clear();
            updateDatabase();
        }
    }

    ActivityIndicator {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        running: issueListModel.count === 0 && !root.err
    }

    ListView {
        visible: issueListModel.count > 0 && !root.err
        anchors.fill: parent
        width: parent.width
        height: parent.height

        model: issueListModel

        delegate: ListItem.Standard {
            text: model.title
            iconSource: Qt.resolvedUrl(model.image)
            progression: true
            onClicked: root.openIssue(model.id)
        }
    }
}
