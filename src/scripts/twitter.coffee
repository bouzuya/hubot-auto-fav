Twitter = require 'twitter'

# monkey patch for "twitter": "0.2.9"
Twitter.prototype.createFavorite = (params, callback) ->
  url = '/favorites/create.json'
  @post url, params, null, callback
  @

module.exports = Twitter
