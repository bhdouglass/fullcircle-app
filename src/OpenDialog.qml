import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.1

PopupBase {
    id: openDialog
    anchors.fill: parent
    property var activeTransfer
    property var path

    Rectangle {
        anchors.fill: parent

        ContentItem {
            id: exportItem
        }

        ContentPeerPicker {
            id: peerPicker
            visible: openDialog.visible
            handler: ContentHandler.Destination
            contentType: ContentType.Documents

            onPeerSelected: {
                activeTransfer = peer.request();
                var items = [];
                exportItem.url = path;
                console.log(path);
                items.push(exportItem);
                activeTransfer.items = items;
                activeTransfer.state = ContentTransfer.Charged;

                PopupUtils.close(openDialog)
            }

            onCancelPressed: {
                PopupUtils.close(openDialog)
            }
        }
    }
}
