import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import U1db 1.0 as U1db
import "bundle.js" as Bundle

Page {
    id: root
    title: i18n.tr('Full Circle Magazine')

    property bool err: false
    property bool loading: false
    signal openIssue(string issueId)

    U1db.Database {
        id: metadatadb
        path: 'fullcircle.bhdouglass.metadata.v3'
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

    function refresh() {
        root.loading = true;
        var lastChecked = metadatadb.getDoc('lastChecked');
        if (lastChecked) {
            lastChecked = Bundle.modules.moment(lastChecked);
        }

        updateModel();
        Bundle.modules.fetchIssues(function(err, issues, lc) {
            if (err) {
                console.error('error: ' + err);

                //Only show an error if there isn't any data or the data is older than 7 days
                var now = Bundle.modules.moment();
                if (now.diff(lastChecked, 'days') > 7 || issueListModel.count === 0) {
                    root.err = true;
                }

                root.loading = false;
            }
            else {
                metadatadb.putDoc(Bundle.modules.moment().unix(), 'lastChecked');
                for (var index in issues) {
                    issuesdb.putDoc(issues[index], issues[index].id);
                }

                updateModel();
                root.loading = false;
            }
        });
    }

    Component.onCompleted: {
        Bundle.setupTimeout(timer);
        refresh();
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
            refresh();
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
