var axios = require('axios');
var moment = require('moment');

function fetchIssues(callback) {
  //axios.get('https://www.kimonolabs.com/api/dsun5vv4?&apikey=VcJUuOZizXZr5J7vwfFzff3Tt6m6q5t7&kimmodify=1')
  axios.get('http://bhdouglass.com/fcm.json')
  .then(function(res) {
    console.log('request was successful');
    if (res.data.results) {
      callback(null, res.data.results);
    }
    else {
      callback('Could not fetch issue list');
    }
  }).catch(function(res) {
    console.error('request error: ' + JSON.stringify(res));
    callback('Could not fetch issue list');
  });
}

exports.fetchIssues = fetchIssues;
exports.moment = moment;
