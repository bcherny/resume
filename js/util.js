define(function(require) {
  var util;
  return util = {
    strtotime: function(string) {
      return new Date("" + string + "-01T12:00:00");
    },
    log: function(message) {
      var time;
      time = +new Date();
      if (!this.time) {
        this.time = time;
      }
      console.log(message, " (" + (time - this.time) + "ms)");
      return this.time = time;
    }
  };
});
