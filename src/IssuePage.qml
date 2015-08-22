import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import U1db 1.0 as U1db
import "moment.js" as Moment

Page {
    id: root

    property string img: ""
    property string link: ""
    property string issueId: ""
    property string description: ""
    signal download(string name, string url)

    Component.onCompleted: {
        var update = true;
        var docs = u1db.listDocs();
        if (docs.length > 1) {
            var doc = u1db.getDoc(docs[0]);

            if (doc.fetchTime && Moment.moment().diff(doc.fetchTime, 'days') <= 3) {
                update = false;
            }
        }

        if (update) {
            console.log('going to update issue info');
            updateDatabase();
        }
        else {
            console.log('no need to update issue info');
            updateModel()
        }

        update = true;
        docs = u1dbImages.listDocs();
        if (docs.length > 1) {
            var doc = u1dbImages.getDoc(docs[0]);

            if (doc.fetchTime && Moment.moment().diff(doc.fetchTime, 'days') <= 3) {
                update = false;
            }
        }

        if (update) {
            console.log('going to update images');
            updateImageDatabase();
        }
        else {
            console.log('no need to update images');
            updateImage()
        }
    }

    onIssueIdChanged: {
        updateModel();
        updateImage();
    }

    U1db.Database {
        id: u1db
        path: "fullcircle.bhdouglass.issueInfo"
    }

    U1db.Database {
        id: u1dbImages
        path: "fullcircle.bhdouglass.issueImages"
    }

    function updateDatabase() {
        var xhr = new XMLHttpRequest;
        xhr.open('GET', 'https://www.kimonolabs.com/api/a7tiwn4m?apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1');

        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var json = JSON.parse(xhr.responseText).results;

                var info = {};
                for (var index in json.downloads) {
                    if (!info[index]) {
                        info[index] = {};
                    }

                    info[index].downloads = json.downloads[index];
                }

                for (var index in json.descriptions) {
                    if (!info[index]) {
                        info[index] = {};
                    }

                    info[index].description = json.descriptions[index];
                }

                for (var index in info) {
                    var now = Moment.moment();
                    info[index].fetchTime = now.valueOf();

                    u1db.putDoc(info[index], index.replace('-', '_'));
                }

                updateModel();
            }
        }

        xhr.send();
    }

    function updateImageDatabase() {
        var xhr = new XMLHttpRequest;
        xhr.open('GET', 'https://www.kimonolabs.com/api/aqhdeyvu?apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1');

        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var json = JSON.parse(xhr.responseText).results.images;

                for (var index in json) {
                    var now = Moment.moment();
                    json[index].fetchTime = now.valueOf();

                    u1dbImages.putDoc(json[index], index.replace('-', '_'));
                }

                updateImage();
            }
        }

        xhr.send();
    }

    function updateModel() {
        downloadsModel.clear();
        description = ""

        if (issueId) {
            var update = true;
            var doc = u1db.getDoc(issueId.replace('-', '_'));

            if (doc) {
                update = false;

                if (doc.downloads) {
                    for (var index in doc.downloads) {
                        downloadsModel.append(doc.downloads[index]);
                    }
                }

                if (doc.description) {
                    description = doc.description;
                }
            }

            if (update) {
                updateDatabase();
            }
        }
    }

    function updateImage() {
        if (issueId) {
            var update = true;
            var doc = u1dbImages.getDoc(issueId.replace('-', '_'));

            if (doc) {
                if (doc.image) {
                    update = false;
                    img = doc.image;
                }
            }

            if (update) {
                updateImageDatabase();
            }
        }
    }

    Rectangle {
        id: container

        height: childrenRect.height
        color: 'transparent'

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: units.gu(1)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        UbuntuShape {
            id: image

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            width: parent.width * (3/4)
            height: width / 2

            sourceFillMode: UbuntuShape.PreserveAspectCrop
            source: Image {
                source: root.img
            }
        }

        Flickable {
            id: labelFlick

            anchors {
                top: image.bottom
                topMargin: units.gu(2)
            }

            width: parent.width
            height: root.height / 2
            contentWidth: parent.width
            contentHeight: label.height

            flickableDirection: Flickable.VerticalFlick
            clip: true

            Label {
                id: label

                width: parent.width
                text: description
                wrapMode: Text.WordWrap
            }
        }
    }

    ListModel {
        id: downloadsModel
    }

    ListView {
        width: parent.width
        anchors {
            top: container.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }

        model: downloadsModel
        delegate: ListItem.Standard {
            text: i18n.tr('Download: ') + model.lang + ' ' + i18n.tr('PDF')
            progression: true
            onClicked: root.download(root.title + ' (' + model.lang + ' ' + i18n.tr('PDF') + ')', model.link)
        }
    }
}
