import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: root

    signal openIssue(string title, string img, string link, string issueId)

    title: i18n.tr("Full Circle Magazine")

    Component.onCompleted: {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://www.kimonolabs.com/api/6tvvisv6?apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1");

        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var json = JSON.parse(xhr.responseText).results;

                json.reverse();
                issuesListModel.clear();
                for (var index in json) {
                    issuesListModel.append(json[index]);
                }
            }
        }

        xhr.send();
    }

    Column {
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        ListModel {
            id: issuesListModel
        }

        ActivityIndicator {
            running: issuesListModel.count === 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ListView {
            anchors.top: parent.top
            width: parent.width
            height: parent.height

            model: issuesListModel

            delegate: ListItem.Standard {
                text: model.title
                iconSource: Qt.resolvedUrl(model.img)
                progression: true
                onClicked: root.openIssue(model.title, model.img, model.link, model.id)
            }
        }
    }
}
