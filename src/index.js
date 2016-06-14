var URL = 'http://dl.fullcirclemagazine.org/fcm-main.json';

function fetchIssues(callback) {
    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                var data = JSON.parse(xhr.responseText);
                console.log('request was successful');

                var issues = [];
                for (var key in data) {
                    if (key != 'limit') {
                        var issue = data[key];
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

                issues = issues.sort(function(a, b) { //reverse sort by id to put latest issues on the top
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
            }
            else {
                callback('Failed to fetch issue list');
            }
        }
    };

    xhr.open('GET', URL, true);
    xhr.send();
}

function updateIssueModel(model, db) {
    var issues = [];
    var docs = db.listDocs();
    for (var index in docs) {
        var issue = db.getDoc(docs[index]);

        if (issue && issue.title) {
            issues.push(issue);
        }
    }

    issues.reverse();
    model.clear();
    for (var index in issues) {
        model.append(issues[index]);
    }
}

function refreshIssues(model, db, callback) {
    updateIssueModel(model, db);
    fetchIssues(function(err, issues) {
        if (err) {
            console.error('error: ' + err);
            callback(err);
        }
        else {
            var ids = [];
            for (var index in issues) {
                db.putDoc(issues[index], issues[index].id);
                ids.push(issues[index].id);
            }

            var docs = db.listDocs();
            for (var index in docs) {
                if (ids.indexOf(docs[index]) == -1) {
                    db.deleteDoc(docs[index]);
                }
            }

            updateIssueModel(model, db);
            callback();
        }
    });
}

function urlToId(url) {
    return url.replace('http://', '').replace('https://', '').replace(/\./g, '_').replace(/\//g, '_');
}
