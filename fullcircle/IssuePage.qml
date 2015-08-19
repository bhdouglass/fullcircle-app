import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: root

    property string img: ""
    property string link: ""
    property string issueId: ""
    property string description: ""
    property var downloads
    property var descriptions
    signal download(string name, string url)

    Component.onCompleted: fetch()
    onIssueIdChanged: update()

    function fetch() {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://www.kimonolabs.com/api/a7tiwn4m?apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1");

        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var json = JSON.parse(xhr.responseText);

                downloads = json.results.downloads;
                descriptions = json.results.descriptions;

                update();
            }
        }

        xhr.send();
    }

    function update() {
        downloadsModel.clear();
        description = ""

        if (issueId) {
            if (downloads) {
                for (var index in downloads[issueId]) {
                    downloadsModel.append(downloads[issueId][index]);
                }
            }

            if (descriptions && descriptions[issueId]) {
                description = descriptions[issueId];
            }
        }

        if (!descriptions || !downloads) {
            fetch();
        }
    }

    Column {
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        UbuntuShape {
            id: image

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * (3/4)
            height: width / 2

            sourceFillMode: UbuntuShape.PreserveAspectCrop
            source: Image {
                source: root.img
            }
        }

        Label {
            id: label

            width: root.width
            anchors {
                topMargin: units.gu(1)
                top: image.bottom
            }

            text: description
            wrapMode: Text.WordWrap
        }

        ListModel {
            id: downloadsModel
        }

        ListView {
            width: parent.width
            anchors {
                top: label.bottom
                bottom: parent.bottom
            }

            model: downloadsModel
            delegate: ListItem.Standard {
                text: "Download: " + model.lang + " PDF"
                progression: true
                onClicked: root.download(root.title + " (" + model.lang + ")", model.link)
            }
        }
    }
}
