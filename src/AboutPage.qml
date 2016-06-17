import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Page {
    id: root

    title: i18n.tr('About')

    header: PageHeader {
        id: header
        title: parent.title
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
                margins: units.gu(2)
            }
            spacing: units.gu(2)

            Label {
                text: i18n.tr('The Full Circle Magazine App\nApp Author: Brian Douglass\nMagazine Editor: Ronnie Tucker')
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                text: i18n.tr('Visit the author\'s website')
                color: UbuntuColors.orange
                onClicked: Qt.openUrlExternally('http://bhdouglass.com/')
                Layout.fillWidth: true
            }

            Button {
                text: i18n.tr('Visit the Full Circle website')
                color: UbuntuColors.orange
                onClicked: Qt.openUrlExternally('http://fullcirclemagazine.org/')
                Layout.fillWidth: true
            }

            Button {
                text: i18n.tr('Get the source')
                color: UbuntuColors.orange
                onClicked: Qt.openUrlExternally('https://github.com/bhdouglass/fullcircle-app')
                Layout.fillWidth: true
            }
        }
    }
}
