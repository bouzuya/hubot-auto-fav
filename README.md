# hubot-auto-fav

A Hubot script for favoriting some tweets automatic.

## Installation

    $ npm install git://github.com/bouzuya/hubot-auto-fav.git

or

    $ # TAG is the package version you need.
    $ npm install 'git://github.com/bouzuya/hubot-auto-fav.git#TAG'

## Configuration

    $ export HUBOT_AUTO_FAV_API_INTERVAL='1000'
    $ export HUBOT_AUTO_FAV_INTERVAL='60000'
    $ export HUBOT_AUTO_FAV_KEYWORDS='["keyword1", "keyword2"]'
    $ export HUBOT_AUTO_FAV_ROOM='room_id'
    $ export HUBOT_AUTO_FAV_API_KEY='twitter api key'
    $ export HUBOT_AUTO_FAV_API_SECRET='twitter api secret'
    $ export HUBOT_AUTO_FAV_ACCESS_TOKEN='twitter access token'
    $ export HUBOT_AUTO_FAV_ACCESS_TOKEN_SECRET='twitter access token secret'

## Commands

    bouzuya> hubot help auto-fav
    hubot> auto-fav - favorite tweets automatic.

## License

MIT

## Badges

[![Build Status][travis-status]][travis]

[travis]: https://travis-ci.org/bouzuya/hubot-auto-fav
[travis-status]: https://travis-ci.org/bouzuya/hubot-auto-fav.svg?branch=master
