
var Twitter;

Twitter = require('twitter');

Twitter.prototype.createFavorite = function(params, callback) {
  var url;
  url = '/favorites/create.json';
  this.post(url, params, null, callback);
  return this;
};

module.exports = Twitter;
