/* jshint node: true */
'use strict';

var Filter = require('broccoli-filter');
var checker = require('ember-cli-version-checker');
var path = require('path');
var _ = require('lodash');

var defaults = _.defaults;
var assign = _.assign;

function TemplateCompiler (inputTree, options) {
  if (!(this instanceof TemplateCompiler)) {
    return new TemplateCompiler(inputTree, options);
  }

  Filter.call(this, inputTree, options); // this._super()

  this.options = options || {};
  this.inputTree = inputTree;

  this.compile = this.options.emblemCompiler || require('emblem').default.compile;
  this.compilerOptions = defaults(options, {
    quiet: false,
    debugging: false
  });
}

TemplateCompiler.prototype = Object.create(Filter.prototype);
TemplateCompiler.prototype.constructor = TemplateCompiler;
TemplateCompiler.prototype.extensions = ['embl', 'emblem', 'em'];
TemplateCompiler.prototype.targetExtension = 'hbs';

TemplateCompiler.prototype.processString = function (string, relativePath) {
  var options = assign({}, this.compilerOptions, { file: relativePath });

  return this.compile(string, options);
}

module.exports = {
  name: 'ember-cli-emblem',
  shouldSetupRegistryInIncluded: function() {
    return !checker.isAbove(this, '0.2.0');
  },
  getConfig: function() {
    var brocfileConfig = {};
    var emblemOptions = defaults(this.project.config(process.env.EMBER_ENV).emblemOptions || {},
      brocfileConfig, {
        blueprints: true
      });

    return emblemOptions;
  },
  blueprintsPath: function() {
    if (this.getConfig().blueprints) {
      return path.join(__dirname, 'blueprints');
    }
  },
  setupPreprocessorRegistry: function(type, registry) {
    var addonContext = this;
    var compiler = {
      name: 'ember-cli-emblem',
      ext: ['embl', 'emblem', 'em'],
      toTree: function(tree) {
        return TemplateCompiler(tree, addonContext.getConfig());
      }
    };
    registry.add('template', compiler);
  },
  included: function(app){
    this._super.included.apply(this, arguments);
    if (this.shouldSetupRegistryInIncluded()) {
      this.setupPreprocessorRegistry('parent', app.registry);
    }
  }

};
