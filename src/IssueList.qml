import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Flickable {
    id: issueList

    property var issues: []
    property bool err: false

    signal refresh()
    signal issueClicked()

    clip: true
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

            visible: issueList.err && issues.length === 0
            text: i18n.tr('Unable to load issue list at this time')
        }

        Button {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            visible: issueList.err && issues.length === 0
            text: i18n.tr('Retry')
            color: UbuntuColors.orange

            onClicked: issueList.refresh()
        }

        Repeater {
            model: issueList.issues

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
                    pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl('IssuePage.qml'), {
                        title: modelData.title,
                        issueId: modelData.id,
                        url: modelData.url,
                        image: modelData.image,
                        description: modelData.description,
                        downloads: modelData.downloads,
                    });

                    issueList.issueClicked();
                }
            }
        }
    }
}
