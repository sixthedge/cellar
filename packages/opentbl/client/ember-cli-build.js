/*jshint node:true*/

/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {

  var APP_OPTIONS = {};

  var app_deploy_target = process.env['APP_DEPLOY_TARGET'];

  if (app_deploy_target === 'staging') {
    APP_OPTIONS.fingerprint = {
      "prepend":    "STAGING-PREPEND",
      "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
    }
  }

  if (app_deploy_target === 'production') {
    APP_OPTIONS.fingerprint = {
      "prepend":    "PRODUCTION-PREPEND",
      "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
    }
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
  app.import('bower_components/pickadate/lib/picker.date.js');
  app.import('bower_components/pickadate/lib/picker.time.js');
  // datepicker theme css
  app.import('bower_components/pickadate/lib/themes/classic.css');
  app.import('bower_components/pickadate/lib/themes/classic.date.css');
  app.import('bower_components/pickadate/lib/themes/classic.time.css');
  // amcharts
  // app.import('bower_components/amcharts/dist/amcharts/amcharts.js');
  // app.import('bower_components/amcharts/dist/amcharts/pie.js');
  // app.import('bower_components/amcharts/dist/amcharts/xy.js');
  // app.import('bower_components/amcharts/dist/amcharts/serial.js');
  // chosen
  // app.import('bower_components/chosen/chosen.jquery.js');
  // app.import('bower_components/chosen/chosen.css');
  // app.import('bower_components/chosen/chosen-sprite.png', {"destDir":"assets"});
  // app.import('bower_components/chosen/chosen-sprite@2x.png', {"destDir":"assets"});
  // color picker
  // app.import('bower_components/colpick/js/colpick.js');
  // fontawesome
  // app.import('bower_components/font-awesome/fonts/FontAwesome.otf', {"destDir":"assets/fonts"});
  // app.import('bower_components/font-awesome/fonts/fontawesome-webfont.woff2', {"destDir":"assets/fonts"});
  // app.import('bower_components/font-awesome/fonts/fontawesome-webfont.svg', {"destDir":"assets/fonts"});
  // app.import('bower_components/font-awesome/fonts/fontawesome-webfont.ttf', {"destDir":"assets/fonts"});
  // app.import('bower_components/font-awesome/fonts/fontawesome-webfont.woff', {"destDir":"assets/fonts"});
  // app.import('bower_components/font-awesome/fonts/fontawesome-webfont.eot', {"destDir":"assets/fonts"});
  // cookies
  // app.import('bower_components/js-cookie/src/js.cookie.js');

  // **totem assets**
  // file_upload js
  // app.import('vendor/file_upload/jquery.fileupload.js');
  // app.import('vendor/file_upload/jquery.iframe-transport.js');

  // **Trees**
  var pick_files = require('broccoli-funnel');
  // ckeditor
  // trees.push(pick_files('bower_components/ckeditor', {"srcDir":"/","include":["ckeditor.js","styles.js"],"destDir":"assets/ckeditor"}));
  // trees.push(pick_files('bower_components/ckeditor', {"srcDir":"adapters","include":["jquery.js"],"destDir":"assets/ckeditor/adapters"}));
  // trees.push(pick_files('bower_components/ckeditor', {"srcDir":"skins/moono","include":["**/*.*"],"destDir":"assets/ckeditor/skins/moono"}));
  // trees.push(pick_files('bower_components/ckeditor', {"srcDir":"lang","include":["*.*"],"destDir":"assets/ckeditor/lang"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"forms","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/forms"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"colorbutton","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/colorbutton"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"panelbutton","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/panelbutton"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"table","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/table"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"image","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/image"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"specialchar","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/specialcar"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"link","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/link"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"justify","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/justify"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"pastefromword","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/pastefromword"}));
  // trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"clipboard","include":["**/*.*"],"destDir":"assets/ckeditor/plugins/clipboard"}));

  // **thinkspace assets**
  // thinkspace fonts
  // trees.push(pick_files('node_modules/thinkspace-assets/fonts', {"srcDir":"icomoon","include":["**/*.*"],"destDir":"assets/fonts"}));
  // thinkspace images
  trees.push(pick_files('node_modules/thinkspace-assets/images', {"srcDir":"/","include":["**/*.*"],"destDir":"assets/images"}));

  return app.toTree(trees);

};
