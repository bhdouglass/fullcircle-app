var axios = require('axios');
var moment = require('moment');

function fetchIssues(callback) {
  axios.get('http://dl.fullcirclemagazine.org/fcm-main.json')
  .then(function(res) {
    console.log('request was successful');

    var issues = [];
    for (var key in res.data) {
      if (key != 'limit') {
        var issue = res.data[key];
        var id = key.replace('issue-', '');
        while (id.length < 3) { //Add leading zeros
          id = '0' + id;
        }

        issue.id = 'issue_' + id;

        var downloads = [];
        for (var lang in issue.links) {
          downloads.push({
            lang: lang,
            link: issue.links[lang],
          });
        }

        delete issue.links;
        issue.downloads = downloads.sort(function(a, b) { //sort by language
          var value = 0;
          if (a.lang < b.lang) {
            value = -1;
          }
          else if (a.lang > b.lang) {
            value = 1;
          }

          return value;
        });

        issues.push(issue);
      }
    }

    issues = issues.sort(function(a, b) { //reverse sort by id
      var value = 0;
      if (a.id > b.id) {
        value = -1;
      }
      else if (a.id < b.id) {
        value = 1;
      }

      return value;
    });

    callback(null, issues);
  }).catch(function(res) {
    console.error('request error: ' + JSON.stringify(res));
    callback('Could not fetch issue list');
  });
}

exports.fetchIssues = fetchIssues;
exports.moment = moment;
