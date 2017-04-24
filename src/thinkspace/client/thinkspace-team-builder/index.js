/* jshint node: true */
'use strict';

module.exports = global.totem_engine_addon.extend({
  name: 'thinkspace-team-builder',
  lazyLoading: false,
  isDevelopingAddon: function() {return true}  // see ember-cli issue #2451
});
