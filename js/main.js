// Generated by CoffeeScript 1.6.3
(function() {
  require.config({
    paths: {
      annie: '../node_modules/annie/annie',
      GMaps: '../node_modules/gmaps/gmaps',
      lodash: '../node_modules/lodash/lodash',
      marked: '../node_modules/marked/lib/marked',
      repocount: '../node_modules/repocount/repocount',
      snap: '../node_modules/Snap.svg/dist/snap.svg',
      strftime: '../node_modules/strftime/strftime',
      umodel: '../node_modules/umodel/umodel',
      uxhr: '../node_modules/uxhr/uxhr'
    },
    shim: {
      strftime: {
        exports: 'strftime'
      }
    }
  });

  define(function(require) {
    var Resume, init, load, uxhr, _;
    _ = require('lodash');
    Resume = require('resume');
    uxhr = require('uxhr');
    init = function(data) {
      return new Resume(_.extend(data, {
        element: document.getElementById('resume')
      }));
    };
    load = function(url, callback) {
      return uxhr(url, {}, {
        complete: function(res) {
          return callback(JSON.parse(res));
        }
      });
    };
    return load('data/data.json', init);
  });

}).call(this);
