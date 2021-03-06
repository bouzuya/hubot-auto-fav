{Robot, User, TextMessage} = require 'hubot'
assert = require 'power-assert'
path = require 'path'
sinon = require 'sinon'
{Promise} = require 'q'

describe 'auto-fav', ->
  beforeEach (done) ->
    @sinon = sinon.sandbox.create()
    # for warning: possible EventEmitter memory leak detected.
    # process.on 'uncaughtException'
    @sinon.stub process, 'on', -> null
    # config
    @originalEnv = process.env
    process.env =
      HUBOT_AUTO_FAV_API_INTERVAL: 0
      HUBOT_AUTO_FAV_KEYWORDS: '["#hitoridokusho"]'
      HUBOT_AUTO_FAV_INTERVAL: 10
      HUBOT_AUTO_FAV_ROOM: 'hitoridokusho'
      HUBOT_AUTO_FAV_SHOW_DETAIL: null
    # twitter
    Twitter = require '../../src/twitter'
    @searchResult =
      statuses: [
        user: { screen_name: 'bouzuya' }
        id_str: '12345'
        favorited: false
      ]
    @sinon.stub Twitter.prototype, 'createFavorite', (params, callback) =>
      @searchResult.statuses[0].favorited = true
      callback({})
    @sinon.stub Twitter.prototype, 'search', (keyword, options, callback) =>
      callback(@searchResult)
    # robot
    @messageRoom = @sinon.spy()
    @robot = new Robot(path.resolve(__dirname, '..'), 'shell', false, 'hubot')
    @robot.messageRoom = @messageRoom
    @robot.adapter.on 'connected', =>
      @robot.load path.resolve(__dirname, '../../src/scripts')
      done()
    @robot.run()

  afterEach (done) ->
    process.env = @originalEnv
    @robot.brain.on 'close', =>
      @sinon.restore()
      done()
    @robot.shutdown()

  describe 'start', ->
    it 'send "https://twitter.com/bouzuya/status/12345"', (done) ->
      setTimeout =>
        try
          assert @messageRoom.callCount is 1
          assert @messageRoom.firstCall.args[1] is \
            'https://twitter.com/bouzuya/status/12345'
          done()
        catch e
          done e
      , 100
