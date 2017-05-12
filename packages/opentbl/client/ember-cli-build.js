/*jshint node:true*/

/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {

  var APP_OPTIONS = {};

  var app_deploy_target = process.env['APP_DEPLOY_TARGET'];

  APP_OPTIONS.fingerprint = {
    "prepend":    process.env['APP_DEPLOY_FINGERPRINT_PREPEND'],
    "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
  }

  APP_OPTIONS.sassOptions = {
    "includePaths": [
        "node_modules/totem-assets/styles",
        "node_modules/thinkspace-assets/styles",
        "bower_components/foundation-sites/scss"
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
  // pick a date
  app.import('bower_components/pickadate/lib/picker.js');
  app.import('bower_components/pickadate/lib/picker.time.js');
  app.import('bower_components/pickadate/lib/picker.date.js');
  // rangeslider css
  app.import('bower_components/rangeslider.js/dist/rangeslider.css');
  // rangeslider js
  app.import('bower_components/rangeslider.js/dist/rangeslider.js');

  // **Trees**
  var pick_files = require('broccoli-funnel');
  // thinkspace-assets images
  trees.push(pick_files('node_modules/thinkspace-assets/images', {"srcDir":"/","include":["**/*.*"],"destDir":"assets/images"}));

  return app.toTree(trees);

};
