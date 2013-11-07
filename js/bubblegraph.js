// Generated by CoffeeScript 1.6.3
define(function(require) {
  var BubbleGraph, umodel, util, _;
  _ = require('lodash');
  umodel = require('umodel');
  util = require('util');
  return BubbleGraph = (function() {
    BubbleGraph.prototype.options = {
      colors: [],
      data: {},
      element: document.body
    };

    BubbleGraph.prototype.model = new umodel({
      active: null
    });

    BubbleGraph.prototype.animations = {
      active: Raphael.animation({
        opacity: 1,
        'stroke-width': 5
      }, 200),
      inactive: Raphael.animation({
        opacity: .5,
        'stroke-width': 0
      }, 200),
      over: Raphael.animation({
        opacity: .7
      }, 200),
      out: Raphael.animation({
        opacity: .5
      }, 200)
    };

    function BubbleGraph(options) {
      _.extend(this.options, options);
      this.render();
    }

    BubbleGraph.prototype.render = function() {
      var data, days, diff, height, item, last, max, paper, prev, size, spans, time, _i, _len,
        _this = this;
      data = this.options.data;
      size = this.options.element.getBoundingClientRect();
      height = size.height / 3;
      paper = Raphael(this.options.element, size.width, size.height);
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        time = item.when;
        if (time != null) {
          time[0] = util.strtotime(time[0]);
          time[1] = util.strtotime(time[1]);
          diff = Math.abs(time[1].getTime() - time[0].getTime());
          days = Math.ceil(diff / (1000 * 3600 * 24));
          item.timespan = days;
        }
      }
      spans = _.pluck(data, 'timespan');
      max = _.max(spans);
      last = data.length - 1;
      prev = {
        r: null,
        x: null,
        y: null
      };
      return _.each(data, function(item, n) {
        var circle, className, r, x, y;
        className = "color" + (n % 5);
        r = size.width * item.timespan / (2 * max * Math.PI);
        r += max / (5 * r);
        if (prev.x) {
          y = (size.height - height) / 2 - .3 * r + _.random(0, 100);
          x = prev.x + Math.sqrt(Math.abs((y - prev.y) * (y - prev.y) - (r + prev.r) * (r + prev.r)));
        } else {
          x = 20 + r;
          y = size.height - r - 20;
        }
        circle = paper.circle(x, y, r);
        circle.mouseover(function() {
          return _this.over(circle);
        });
        circle.mouseout(function() {
          return _this.out(circle);
        });
        circle.click(function() {
          return _this.click(circle);
        });
        if (n === last) {
          className += ' throb';
        }
        circle.node.setAttribute('class', className);
        circle.node.setAttribute('data-id', n);
        circle.attr({
          opacity: .5,
          stroke: '#fff',
          'stroke-width': 0
        });
        return prev = {
          circle: circle,
          r: r,
          x: x,
          y: y
        };
      });
    };

    BubbleGraph.prototype.clearThrobber = function() {
      var element;
      element = document.querySelector('.throb');
      if (element) {
        return element.classList.remove('throb');
      }
    };

    BubbleGraph.prototype.deactivate = function() {
      var circle, pane,
        _this = this;
      circle = this.model.get('active');
      pane = document.querySelector('.detail.active');
      if (circle) {
        setTimeout(function() {
          var className;
          className = circle.node.className;
          circle.node.className = circle.node.getAttribute('class');
          circle.animate(_this.animations.inactive);
          return circle.transform('s1');
        }, 10);
        this.model.set('active', null);
      }
      if (pane) {
        pane.classList.remove('active');
        setTimeout(function() {
          return pane.classList.add('hide');
        }, .2);
        return document.querySelector('#details').classList.add('hide');
      }
    };

    BubbleGraph.prototype.activate = function(element) {
      var classList, className, id;
      className = element.attr('class');
      id = element.node.getAttribute('data-id');
      element.attr('class', "" + className + " active");
      document.querySelector('#details').classList.remove('hide');
      classList = document.querySelectorAll('.detail')[id].classList;
      classList.remove('hide');
      classList.add('active');
      element.toFront().animate(this.animations.active).transform('s1.1');
      document.querySelector('svg').classList.add('small');
      return this.model.set('active', element);
    };

    BubbleGraph.prototype.toggle = function(element) {
      if (this.model.get('active') !== element) {
        this.deactivate();
        return this.activate(element);
      } else {
        document.querySelector('svg').classList.remove('small');
        return this.deactivate();
      }
    };

    BubbleGraph.prototype.click = function(element) {
      this.clearThrobber();
      return this.toggle(element);
    };

    BubbleGraph.prototype.over = function(element) {
      var active;
      active = this.model.get('active');
      if (element !== active) {
        return element.animate(this.animations.over);
      }
    };

    BubbleGraph.prototype.out = function(element) {
      var active;
      active = this.model.get('active');
      if (element !== active) {
        return element.animate(this.animations.out);
      }
    };

    return BubbleGraph;

  })();
});
