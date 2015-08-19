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
            issuePage.title = title
            issuePage.img = img
            issuePage.link = link
            issuePage.issueId = issueId
            pageStack.push(issuePage)
         }
      }

      IssuePage {
         id: issuePage
         visible: false
         onDownload: {
            downloadPage.name = name
            downloadPage.url = url
            pageStack.push(downloadPage)
         }
      }

      DownloadPage {
         id: downloadPage
         visible: false
      }
   }
}
