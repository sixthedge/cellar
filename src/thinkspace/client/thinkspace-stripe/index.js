/* jshint node: true */
'use strict';

module.exports = {
  name: 'thinkspace-stripe',
  isDevelopingAddon: function() {return true},  // see ember-cli issue #2451
  contentFor: function(type, config, content) {
    if (type === 'head') {
      var add = [];
      add.push("<script src='https://js.stripe.com/v3/'></script>");
      return add.join('\n');
    }
  }
}
