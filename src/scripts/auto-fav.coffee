# Description
#   auto-fav
#
# Dependencies:
#   "q": "^1.0.1",
#   "twitter": "^0.2.9"
#
# Configuration:
#  HUBOT_AUTO_FAV_API_INTERVAL
#  HUBOT_AUTO_FAV_INTERVAL
#  HUBOT_AUTO_FAV_KEYWORDS
#  HUBOT_AUTO_FAV_ROOM
#  HUBOT_AUTO_FAV_API_KEY
#  HUBOT_AUTO_FAV_API_SECRET
#  HUBOT_AUTO_FAV_ACCESS_TOKEN
#  HUBOT_AUTO_FAV_ACCESS_TOKEN_SECRET
#
# Commands:
#   None
#
# Author:
#   bouzuya <m@bouzuya.net>
#
{Promise} = require 'q'
Twitter = require './twitter'

module.exports = (robot) ->

  apiInterval = parseInt(process.env.HUBOT_AUTO_FAV_API_INTERVAL ? '1000', 10)
  interval = parseInt(process.env.HUBOT_AUTO_FAV_INTERVAL ? '60000', 10)
  keywords = JSON.parse(process.env.HUBOT_AUTO_FAV_KEYWORDS ? '[]').map (k) ->
    { q: k }
  room = process.env.HUBOT_AUTO_FAV_ROOM
  twitter = new Twitter
    consumer_key: process.env.HUBOT_AUTO_FAV_API_KEY
    consumer_secret: process.env.HUBOT_AUTO_FAV_API_SECRET
    access_token_key: process.env.HUBOT_AUTO_FAV_ACCESS_TOKEN
    access_token_secret: process.env.HUBOT_AUTO_FAV_ACCESS_TOKEN_SECRET

  favorite = (id) ->
    new Promise (resolve, reject) ->
      twitter.createFavorite { id: id }, (data) ->
        setTimeout ->
          if data instanceof Error
            reject(data)
          else
            resolve(data)
        , apiInterval

  search = (keyword, options) ->
    new Promise (resolve, reject) ->
      twitter.search keyword, options, (data) ->
        setTimeout ->
          if data instanceof Error
            reject(data)
          else
            resolve(data.statuses)
        , apiInterval

  forEachSeries = (arr, f) ->
    arr.reduce (thenable, item) ->
      thenable.then -> f item
    , Promise.resolve()

  tweetUrl = (tweet) ->
    "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id_str}"

  searchAndFavorite = (keyword) ->
    options = if keyword.sinceId? then { since_id: keyword.sinceId } else {}
    search keyword.q, options
      .then (tweets) ->
        robot.logger.debug "auto-fav search " +
          "length=#{tweets.length} sinceId=#{keyword.sinceId}"
        oldSinceId = keyword.sinceId
        keyword.sinceId = tweets[0].id_str if tweets.length > 0
        if oldSinceId? then tweets.filter((tweet) -> !tweet.favorited) else []
      .then (tweets) ->
        robot.logger.debug "auto-fav filter length=#{tweets.length}"
        forEachSeries tweets, (tweet) ->
          favorite tweet.id_str
            .then ->
              robot.logger.debug "auto-fav favorite id_str=#{tweet.id_str}"
              robot.messageRoom room, tweetUrl(tweet) if room?
      .then null, (err) ->
        robot.logger.error err

  watch = ->
    g = -> setTimeout watch, interval
    forEachSeries keywords, (keyword) -> searchAndFavorite keyword
      .then g, g

  watch()
