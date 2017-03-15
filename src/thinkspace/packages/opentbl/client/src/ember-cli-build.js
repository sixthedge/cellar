/*jshint node:true*/

/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {

  var APP_OPTIONS = {};

  APP_OPTIONS.sassOptions = {
    "includePaths": [
        "node_modules/totem-assets/styles",
        "node_modules/thinkspace-assets/styles",
        "bower_components/foundation-sites/scss",
    ],
    "imagePath": "/assets/images"
  }

  var app = new EmberApp(defaults, APP_OPTIONS);

  var trees = [];

  // **Imports**
  // compile runtime templates
  app.import('bower_components/ember/ember-template-compiler.js');
  // foundation.min
  app.import('bower_components/foundation-sites/dist/foundation.min.js');

  // **Trees**
  var pick_files = require('broccoli-funnel');
  // thinkspace-assets images
  trees.push(pick_files('node_modules/thinkspace-assets/images', {"srcDir":"/","include":["**/*.*"],"destDir":"assets/images"}));

  return app.toTree(trees);

};
