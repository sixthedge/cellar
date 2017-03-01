/* jshint node: true */
'use strict';

var engine_addon  = require(require('path').resolve('.', 'node_modules', 'ember-engines/lib/engine-addon'));
var totem_engines = {
  name: 'totem-engines',
  isDevelopingAddon: function() {return true}  // see ember-cli issue #2451
};

// Node 'require' uses the 'linked' engine's root path for module lookup so
// ember modules (e.g. ember-engines/lib/engine-add) will not be found.
// 'engine_addon' is set to the node's 'node_modules' module
// and other engines can just use this global.
global.totem_engine_addon = engine_addon;

module.exports            = totem_engines;
