import QtQuick 2.4
import Ubuntu.Components 1.2

Page {
    id: root

    title: i18n.tr('About')

    Label {
        id: label

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        text: i18n.tr('The Full Circle Magazine App\nApp Author: Brian Douglass\nMagazine Editor: Ronnie Tucker')
        wrapMode: Text.WordWrap
    }

    Button {
        id: authorButton

        width: fcmButton.width
        anchors {
            top: label.bottom
            topMargin: units.gu(3)
            horizontalCenter: parent.horizontalCenter
        }

        text: i18n.tr('Visit the author\'s website')
        color: UbuntuColors.orange
        onClicked: Qt.openUrlExternally('http://bhdouglass.com/')
    }

    Button {
        id: fcmButton

        anchors {
            top: authorButton.bottom
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        text: i18n.tr('Visit the Full Circle website')
        color: UbuntuColors.orange
        onClicked: Qt.openUrlExternally('http://fullcirclemagazine.org/')
    }

    Button {
        id: sourceButton

        width: fcmButton.width
        anchors {
            top: fcmButton.bottom
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        text: i18n.tr('Get the source')
        color: UbuntuColors.orange
        onClicked: Qt.openUrlExternally('https://github.com/bhdouglass/fullcircle-app')
    }
}
