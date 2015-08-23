import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import U1db 1.0 as U1db
import "moment.js" as Moment //https://plus.google.com/+MikkoAhlroth/posts/JW67rSDkMeH

Page {
    id: root
    title: i18n.tr('Full Circle Magazine')

    property bool err: false
    signal openIssue(string title, string img, string link, string issueId)

    U1db.Database {
        id: u1db
        path: 'fullcircle.bhdouglass.issues'
    }

    Component.onCompleted: {
        updateModel();

        var update = true;
        var docs = u1db.listDocs();
        if (docs.length > 1) {
            var doc = u1db.getDoc(docs[0]);

            if (doc.fetchTime && Moment.moment().diff(doc.fetchTime, 'days') <= 3) {
                update = false;
            }
        }

        if (update) {
            console.log('going to update issue list');
            updateDatabase();
        }
        else {
            console.log('no need to update issue list');
            updateModel();
        }
    }

    function updateModel() {
        var issues = [];
        var docs = u1db.listDocs();
        for (var index in docs) {
            issues.push(u1db.getDoc(docs[index]));
        }

        issues.reverse();
        issueListModel.clear();
        for (var index in issues) {
            issueListModel.append(issues[index]);
        }
    }

    function updateDatabase() {
        var xhr = new XMLHttpRequest;
        xhr.open('GET', 'https://www.kimonolabs.com/api/6tvvisv6?apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1');

        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                console.log('issue list response code: ' + xhr.status);
                if (xhr.status == 200) {
                    root.err = false;
                    var json = JSON.parse(xhr.responseText).results;

                    for (var index in json) {
                        var split = json[index].id.split('-');
                        while (split[1].length < 3) { //Add leading zeros
                            split[1] = '0' + split[1];
                        }
                        var id = split[0] + '_' + split[1];

                        var now = Moment.moment();
                        json[index].fetchTime = now.valueOf();

                        u1db.putDoc(json[index], id);
                    }

                    updateModel();
                }
                else {
                    root.err = true;
                    var docs = u1db.listDocs();
                    if (docs.length > 1) {
                        var doc = u1db.getDoc(docs[0]);

                        //Only show error if more than a week out of date
                        if (doc.fetchTime && Moment.moment().diff(doc.fetchTime, 'days') <= 7) {
                            root.err = false;
                        }
                    }
                }
            }
        }

        xhr.send();
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
            iconSource: Qt.resolvedUrl(model.img)
            progression: true
            onClicked: root.openIssue(model.title, model.img, model.link, model.id)
        }
    }
}
