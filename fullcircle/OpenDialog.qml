import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.1

PopupBase {
    id: root
    anchors.fill: parent
    property var activeTransfer
    property var downloadId
    //property alias contentType: peerPicker.contentType

    Rectangle {
        anchors.fill: parent

        /*Loader {
            id: peerModelLoader
            active: true
            asynchronous: false
            sourceComponent: ContentPeerModel { }
            onLoaded: {
                console.log('loaded');
                //item.handler = peerPicker.handler;
                peerModelLoader.item.handler = ContentHandler.Destination;
                //item.contentType = peerPicker.contentType;
                peerModelLoader.item.contentType = ContentType.Documents;
                console.log(item.peers.length);
            }
            onStatusChanged: console.log('status: ' + peerModelLoader.status)
        }*/

        ContentPeerPicker {
            id: peerPicker
            visible: root.visible
            //customPeerModelLoader: peerModelLoader
            handler: ContentHandler.Destination
            //handler: ContentHandler.Share
            //visible: parent.visible
            contentType: ContentType.Documents
            //contentType: ContentType.All

            onPeerSelected: {
                activeTransfer = peer.request()
                activeTransfer.downloadId = root.downloadId
                activeTransfer.state = ContentTransfer.Downloading

                PopupUtils.close(root)
            }

            onCancelPressed: {
                PopupUtils.close(root)
            }
        }
    }
}
