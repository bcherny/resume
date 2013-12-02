// Generated by CoffeeScript 1.6.3
(function() {
  define(function(require) {
    var BubbleGraph, GMaps, Resume, annie, marked, strftime, umodel, util, uxhr, _;
    _ = require('lodash');
    annie = require('annie');
    BubbleGraph = require('bubblegraph');
    GMaps = require('GMaps');
    marked = require('marked');
    strftime = require('strftime');
    umodel = require('umodel');
    util = require('util');
    uxhr = require('uxhr');
    return Resume = (function() {
      Resume.prototype.options = {
        name: 'John Smith',
        contact: {},
        element: document.body,
        history: [],
        objective: '',
        skills: [],
        colors: ['0B486B', 'A8DBA8', '79BD9A', '3B8686', 'CFF09E'],
        templateHeader: function() {
          var contacts, key, value, _labels, _ref, _template;
          _labels = {
            email: 'Email',
            github: 'GitHub',
            npm: 'NPM',
            www: 'Web'
          };
          _template = function(type, value) {
            switch (type) {
              case 'email':
                return "mailto:" + value;
              case 'github':
                return "https://github.com/" + value;
              case 'npm':
                return "https://npmjs.org/~" + value;
              case 'www':
                if (value.indexOf('http') !== 0) {
                  return "http://" + value;
                } else {
                  return value;
                }
            }
          };
          contacts = '';
          _ref = this.contact;
          for (key in _ref) {
            value = _ref[key];
            contacts += "<li><a class=\"" + key + "\" href=\"" + (_template(key, value)) + "\">" + _labels[key] + "</a></li>";
          }
          return "<header>\n	<h1>" + this.name + "'s Resume</h1>\n	<ul>" + contacts + "</ul>\n</header>";
        },
        templateCover: function() {
          var skills;
          skills = '<span class="tag">' + this.skills.join('</span><span class="tag">') + '</span>';
          return "<div id=\"cover\">\n	<h3 id=\"objective\">" + (marked(this.objective)) + "</h3>\n	<div id=\"skills\">" + skills + "</div>\n</div>";
        },
        templateHistory: function() {
          return "<div id=\"details\" class=\"hide\">\n	" + this.content + "\n</div>";
        },
        templateHistoryItem: function() {
          var data, date, fields, from, item, location, map, responsibilities, skills, to, _i, _len;
          if (this.when[1] === null) {
            date = new Date();
            this.when[1] = "" + (date.getFullYear()) + "-" + (date.getMonth());
          }
          from = strftime('%B %Y', util.strtotime(this.when[0]));
          to = strftime('%B %Y', util.strtotime(this.when[1]));
          if (this.location) {
            location = (this.location.city ? "" + this.location.city + "," : '') + ' ' + (this.location.state || '');
          } else {
            location = '';
          }
          responsibilities = '- ' + this.responsibilities.join('\n- ');
          skills = '<span class="tag">' + this.skills.join('</span><span class="tag">') + '</span>';
          data = [
            {
              field: 'company',
              value: "**" + this.company + "**"
            }, {
              field: 'title',
              value: this.title
            }, {
              field: 'location',
              value: location
            }, {
              field: 'when',
              value: "" + from + " - " + to
            }, {
              field: 'description',
              value: this.description
            }, {
              field: 'responsibilities',
              value: responsibilities
            }, {
              field: 'skills',
              value: skills
            }
          ];
          fields = '';
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            if (item.value != null) {
              fields += "<dt>" + item.field + "</dt><dd>" + (marked(item.value)) + "</dd>";
            }
          }
          map = this.location ? "<span class=\"map-placeholder\">\n	Loading<br />\n	map...\n	<span class=\"spinner\"></span>\n</span>" : '';
          return "<section class=\"detail hide\">\n	" + map + "\n	<dl>\n		" + fields + "\n	</dl>\n</section>";
        }
      };

      Resume.prototype.model = new umodel({
        graph: null
      });

      function Resume(options) {
        var _this = this;
        _.extend(this.options, options);
        this.attachEvents();
        document.title = "" + this.options.name + "'s Resume";
        setTimeout(function() {
          return _this.render();
        }, 0);
        this.resize();
      }

      Resume.prototype.attachEvents = function() {
        var _this = this;
        document.addEventListener('click', function(e) {
          return _this.clickBody(e);
        });
        window.addEventListener('resize', function() {
          return _this.resize;
        });
        return window.addEventListener('deviceorientation', function() {
          return _this.resize;
        });
      };

      Resume.prototype.clickBody = function(event) {
        var element, graph, isCircle, isClickMeText, isDetails;
        element = event.target;
        isCircle = this.isCircle(element);
        isDetails = this.getDetails(element);
        isClickMeText = this.isClickMeText(element);
        graph = this.model.get('graph');
        if (!isCircle && !isDetails && !isClickMeText && graph) {
          graph.deactivate();
          return util.classList.remove(document.querySelector('svg'), 'small');
        }
      };

      Resume.prototype.isCircle = function(element) {
        return element.tagName === 'circle';
      };

      Resume.prototype.isDetails = function(element) {
        return element.id === 'details';
      };

      Resume.prototype.isClickMeText = function(element) {
        return element.id === 'clickme';
      };

      Resume.prototype.getDetails = function(element) {
        while (element !== document) {
          if (this.isDetails(element)) {
            return element;
          }
          element = element.parentNode;
        }
      };

      Resume.prototype.render = function() {
        var queue,
          _this = this;
        util.log('rendering...');
        queue = {
          renderHistory: 'rendered history!',
          renderBubbles: 'rendered bubbles!',
          clearSpinner: null,
          renderMaps: 'rendered maps!',
          getRepoCount: 'rendered repo counts!'
        };
        return _.each(queue, function(message, fn) {
          _.defer(_.bind(_this[fn], _this));
          if (message) {
            return util.log(message);
          }
        });
      };

      Resume.prototype.clearSpinner = function() {
        var spinner;
        spinner = document.querySelector('#loading');
        return util.classList.add(spinner, 'fade-out');
      };

      Resume.prototype.renderHistory = function() {
        var html, htmlDetails, item, _i, _len, _ref;
        html = htmlDetails = '';
        html += this.options.templateHeader.call(this.options);
        html += this.options.templateCover.call(this.options);
        _ref = this.options.history;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          htmlDetails += this.options.templateHistoryItem.call(item);
        }
        html += this.options.templateHistory.call({
          content: htmlDetails
        });
        return this.options.element.innerHTML = html;
      };

      Resume.prototype.renderBubbles = function() {
        var graph;
        graph = new BubbleGraph({
          colors: this.options.colors,
          data: this.options.history,
          element: this.options.element
        });
        return this.model.set('graph', graph);
      };

      Resume.prototype.renderMaps = function() {
        var details, placeholders, width,
          _this = this;
        details = document.querySelector('#details');
        util.classList.remove(details, 'hide');
        width = details.offsetWidth - 20;
        util.classList.add(details, 'hide');
        placeholders = details.querySelectorAll('.map-placeholder');
        return _.each(this.options.history, function(item, n) {
          var address, img, location, src;
          location = item.location;
          if (location) {
            address = "" + (location.address || '') + " " + (location.city || '') + " " + (location.state || '');
            src = GMaps.staticMapURL({
              address: address,
              markers: [
                {
                  color: _this.options.colors[n % _this.options.colors.length],
                  address: address
                }
              ],
              size: [width, 150],
              zoom: 9
            });
            img = document.createElement('img');
            img.alt = '';
            img.className = 'map';
            img.src = src;
            return img.onload = function() {
              util.classList.add(placeholders[n], 'fade-out');
              return setTimeout(function() {
                placeholders[n].parentNode.replaceChild(img, placeholders[n]);
                return _.defer(function() {
                  return util.classList.add(img, 'fade-in');
                });
              }, 200);
            };
          }
        });
      };

      Resume.prototype.templateRepoCounts = function(counts) {
        var count, element, platform, _ref, _results;
        _ref = JSON.parse(counts);
        _results = [];
        for (platform in _ref) {
          count = _ref[platform];
          if (typeof count === 'number') {
            _results.push((function() {
              var _i, _len, _ref1, _results1;
              _ref1 = document.querySelectorAll("." + platform);
              _results1 = [];
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                element = _ref1[_i];
                _results1.push(element.innerHTML += " (" + count + ")");
              }
              return _results1;
            })());
          }
        }
        return _results;
      };

      Resume.prototype.getRepoCount = function() {
        return uxhr('http://www.contributor.io/api', this.options.contact, {
          success: this.templateRepoCounts
        });
      };

      Resume.prototype.resize = function() {
        var bin, property, rotate, rule, scale, sheet, value, x, y;
        scale = .7;
        rotate = -60;
        x = -28;
        y = -27;
        bin = Math.floor(this.options.element.offsetHeight / 100);
        if (bin < 5) {
          scale = (bin + 1) / 10;
          rotate = -60 + 20 * (5 - bin);
        }
        property = 'transform';
        value = "scale(" + scale + ") translate3d(" + x + "%, " + y + "%, 0) rotate(" + rotate + "deg);";
        rule = "svg.small {\n	-" + (annie.vendor.toLowerCase()) + "-" + property + ": " + value + "\n	" + property + ": " + value + "\n}";
        sheet = document.styleSheets[0];
        return sheet.insertRule(rule, sheet.cssRules.length);
      };

      return Resume;

    })();
  });

}).call(this);
