'use strict';

exports.compile = compile;

var parser = require('./parser');
var EmberDelegate = require('./parser-delegate/ember');
var preprocessor = require('./preprocessor');
var template_compiler = require('./template-compiler');
var ast_builder = require('./ast-builder');



/**
  options can include:
    quite: disable deprecation notices
    debugging: show output handlebars in console
*/

function compile(emblem, customOptions) {
  var builder = ast_builder.generateBuilder();
  var options = customOptions || {};
  var processedEmblem = preprocessor.processSync(emblem);

  options.builder = builder;
  parser.parse(processedEmblem, options);

  var ast = builder.toAST();
  var result = template_compiler.compile(ast);

  if (options.debugging) {
    console.log(result);
  }

  return result;
}