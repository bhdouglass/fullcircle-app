import QtQuick 2.4
import Ubuntu.Components 1.2

MainView {
   objectName: "mainView"
   applicationName: "fullcircle.bhdouglass"
   automaticOrientation: true

   width: units.gu(45)
   height: units.gu(75)

   PageStack {
      id: pageStack
      Component.onCompleted: push(issueListPage)

      IssueListPage {
         id: issueListPage
         visible: false

         onOpenIssue: {
            issuePage.issueId = issueId
            pageStack.push(issuePage)
         }

         head.actions: [
            Action {
               iconName: 'info'
               text: i18n.tr('About')
               onTriggered: pageStack.push(aboutPage);
            }
         ]
      }

      IssuePage {
         id: issuePage
         visible: false
         onDownload: {
            downloadPage.name = name
            downloadPage.url = url
            pageStack.push(downloadPage)
         }

         head.actions: [
            Action {
               iconName: 'info'
               text: i18n.tr('About')
               onTriggered: pageStack.push(aboutPage);
            }
         ]
      }

      DownloadPage {
         id: downloadPage
         visible: false

         head.actions: [
            Action {
               iconName: 'info'
               text: i18n.tr('About')
               onTriggered: pageStack.push(aboutPage);
            }
         ]
      }

      AboutPage {
         id: aboutPage
         visible: false
      }
   }
}
