/* jshint node: true */
'use strict';

module.exports = global.totem_engine_addon.extend({
  lazyLoading: false,
  name: 'thinkspace-toolbar',
  isDevelopingAddon: function() {return true}  // see ember-cli issue #2451
})
