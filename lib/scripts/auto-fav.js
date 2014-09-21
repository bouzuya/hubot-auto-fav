// Description
//   auto-fav
//
// Dependencies:
//   "q": "^1.0.1",
//   "twitter": "^0.2.9"
//
// Configuration:
//  HUBOT_AUTO_FAV_API_INTERVAL
//  HUBOT_AUTO_FAV_INTERVAL
//  HUBOT_AUTO_FAV_KEYWORDS
//  HUBOT_AUTO_FAV_ROOM
//  HUBOT_AUTO_FAV_API_KEY
//  HUBOT_AUTO_FAV_API_SECRET
//  HUBOT_AUTO_FAV_ACCESS_TOKEN
//  HUBOT_AUTO_FAV_ACCESS_TOKEN_SECRET
//  HUBOT_AUTO_FAV_SHOW_DETAIL
//
// Commands:
//   None
//
// Author:
//   bouzuya <m@bouzuya.net>
//
var Promise, Twitter;

Promise = require('q').Promise;

Twitter = require('../twitter');

module.exports = function(robot) {
  var apiInterval, favorite, forEachSeries, format, interval, keywords, room, search, searchAndFavorite, showDetail, tweetDetail, tweetUrl, twitter, watch, _ref, _ref1, _ref2;
  showDetail = process.env.HUBOT_AUTO_FAV_SHOW_DETAIL;
  apiInterval = parseInt((_ref = process.env.HUBOT_AUTO_FAV_API_INTERVAL) != null ? _ref : '1000', 10);
  interval = parseInt((_ref1 = process.env.HUBOT_AUTO_FAV_INTERVAL) != null ? _ref1 : '60000', 10);
  keywords = JSON.parse((_ref2 = process.env.HUBOT_AUTO_FAV_KEYWORDS) != null ? _ref2 : '[]').map(function(k) {
    return {
      q: k
    };
  });
  room = process.env.HUBOT_AUTO_FAV_ROOM;
  twitter = new Twitter({
    consumer_key: process.env.HUBOT_AUTO_FAV_API_KEY,
    consumer_secret: process.env.HUBOT_AUTO_FAV_API_SECRET,
    access_token_key: process.env.HUBOT_AUTO_FAV_ACCESS_TOKEN,
    access_token_secret: process.env.HUBOT_AUTO_FAV_ACCESS_TOKEN_SECRET
  });
  favorite = function(id) {
    return new Promise(function(resolve, reject) {
      return twitter.createFavorite({
        id: id
      }, function(data) {
        return setTimeout(function() {
          if (data instanceof Error) {
            return reject(data);
          } else {
            return resolve(data);
          }
        }, apiInterval);
      });
    });
  };
  search = function(keyword, options) {
    return new Promise(function(resolve, reject) {
      return twitter.search(keyword, options, function(data) {
        return setTimeout(function() {
          if (data instanceof Error) {
            return reject(data);
          } else {
            return resolve(data.statuses);
          }
        }, apiInterval);
      });
    });
  };
  forEachSeries = function(arr, f) {
    return arr.reduce(function(thenable, item) {
      return thenable.then(function() {
        return f(item);
      });
    }, Promise.resolve());
  };
  tweetUrl = function(tweet) {
    return "https://twitter.com/" + tweet.user.screen_name + "/status/" + tweet.id_str;
  };
  tweetDetail = function(tweet) {
    return "" + tweet.user.screen_name + ": " + tweet.text + "\n" + (tweetUrl(tweet));
  };
  format = function(tweet) {
    if (showDetail) {
      return tweetDetail(tweet);
    } else {
      return tweetUrl(tweet);
    }
  };
  searchAndFavorite = function(keyword) {
    var options;
    options = keyword.sinceId != null ? {
      since_id: keyword.sinceId
    } : {};
    return search(keyword.q, options).then(function(tweets) {
      var oldSinceId;
      robot.logger.debug("auto-fav search " + ("length=" + tweets.length + " sinceId=" + keyword.sinceId));
      oldSinceId = keyword.sinceId;
      if (tweets.length > 0) {
        keyword.sinceId = tweets[0].id_str;
      }
      if (oldSinceId != null) {
        return tweets.filter(function(tweet) {
          return !tweet.favorited;
        });
      } else {
        return [];
      }
    }).then(function(tweets) {
      robot.logger.debug("auto-fav filter length=" + tweets.length);
      return forEachSeries(tweets, function(tweet) {
        return favorite(tweet.id_str).then(function() {
          robot.logger.debug("auto-fav favorite id_str=" + tweet.id_str);
          if (room != null) {
            return robot.messageRoom(room, format(tweet));
          }
        });
      });
    }).then(null, function(err) {
      return robot.logger.error(err);
    });
  };
  watch = function() {
    var g;
    g = function() {
      return setTimeout(watch, interval);
    };
    return forEachSeries(keywords, function(keyword) {
      return searchAndFavorite(keyword);
    }).then(g, g);
  };
  return watch();
};
