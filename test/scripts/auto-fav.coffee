require '../helper'
{Promise} = require 'q'

describe 'auto-fav', ->
  beforeEach (done) ->
    Twitter = require '../../src/scripts/twitter'
    @originalApiInterval = process.env.HUBOT_AUTO_FAV_API_INTERVAL
    process.env.HUBOT_AUTO_FAV_API_INTERVAL = 0
    @originalKeywords = process.env.HUBOT_AUTO_FAV_KEYWORDS
    process.env.HUBOT_AUTO_FAV_KEYWORDS = '["#hitoridokusho"]'
    @originalInterval = process.env.HUBOT_AUTO_FAV_INTERVAL
    process.env.HUBOT_AUTO_FAV_INTERVAL = 10
    @originalRoom = process.env.HUBOT_AUTO_FAV_ROOM
    process.env.HUBOT_AUTO_FAV_ROOM = 'hitoridokusho'
    @searchResult =
      statuses: [
        user: { screen_name: 'bouzuya' }
        id_str: '12345'
        favorited: false
      ]
    @sinon.stub Twitter.prototype, 'createFavorite', (params, callback) =>
      @searchResult.statuses[0].favorited = true
      callback(@createFavoriteResult)
    @sinon.stub Twitter.prototype, 'search', (keyword, options, callback) =>
      callback(@searchResult)
    @kakashi.scripts = [require '../../src/scripts/auto-fav']
    @kakashi.users = [{ id: 'bouzuya', room: 'hitoridokusho' }]
    done()

  afterEach (done) ->
    process.env.HUBOT_AUTO_FAV_API_INTERVAL = @originalApiInterval
    process.env.HUBOT_AUTO_FAV_KEYWORDS = @originalKeywords
    process.env.HUBOT_AUTO_FAV_INTERVAL = @originalInterval
    process.env.HUBOT_AUTO_FAV_ROOM = @originalRoom
    @kakashi.stop().then done, done

  describe 'start', ->
    it 'send "https://twitter.com/bouzuya/status/12345"', (done) ->
      @kakashi
        .start()
        .then =>
          new Promise (resolve, reject) =>
            setTimeout =>
              try
                expect(@kakashi.send.callCount).to.equal(1)
                expect(@kakashi.send.firstCall.args[1]).to
                  .equal('https://twitter.com/bouzuya/status/12345')
                resolve()
              catch e
                reject e
            , 50
        .then (-> done()), done
