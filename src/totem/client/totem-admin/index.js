/*jshint node:true*/

module.exports = global.totem_engine_addon.extend({
  name: 'totem-admin',
  lazyLoading: false,
  isDevelopingAddon: function() {return true}  // see ember-cli issue #2451
});
