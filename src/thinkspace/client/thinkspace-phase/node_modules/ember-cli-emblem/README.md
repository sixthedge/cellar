[![Circle CI](https://circleci.com/gh/Vestorly/ember-cli-emblem/tree/master.svg?style=svg)](https://circleci.com/gh/Vestorly/ember-cli-emblem/tree/master)
[![Dependency Status](https://david-dm.org/vestorly/ember-cli-emblem.svg?style=flat)](https://david-dm.org/vestorly/ember-cli-emblem)
[![devDependency Status](https://david-dm.org/vestorly/ember-cli-emblem/dev-status.svg?style=flat)](https://david-dm.org/vestorly/ember-cli-emblem#info=devDependencies)

# Ember-cli-emblem

This is an ember-cli addon that brings support for
[Emblem.js](http://emblemjs.com) templates.

This printer is based on version 0.5.0+ of Emblem. It compiles `.embl`,
`.emblem` and `.em` templates into Handlebars-syntax templates which
will then be compiled as standard `.hbs` templates by ember-cli.

Consequently, this addon should be compatible with old versions of Ember
regardless of its template dependency, and support newer (HTMLBars)
template compilation in ember-cli.

## Supporting Ember 1.9.x projects / Handlebars 2.0
The emblem dependency jump from 0.5.x to 0.6.x is breaking change for
projects that use Ember 1.9.x, and through ember-cli:
[ember-cli-htmlbars 0.6.x](https://github.com/ember-cli/ember-cli-htmlbars#handlebars-20-support)
Use ember-cli-emblem v0.2.x for Handlebars 2.0 support.


## Installation

If you are using the `broccoli-emblem-compiler` it should be removed
before using this addon: `npm uninstall --save-dev broccoli-emblem-compiler`.

* `ember install ember-cli-emblem`

## Blueprints

ember-cli-emblem supports blueprint generation for routes, components, and templates. Use the `ember generate` command to add new Emblem templates.

## Options

ember-cli-emblem exposes a few instrumentation options for Emblem:

  - `blueprints: false` if true, will disable blueprint generation.  (default: false);
  - `quiet: false` if true, will quiet Emblem's deprecation notices.  (default: false)
  - `debugging: false`  if true, will output the handlebars output of Emblem to STDOUT. (default: false)

Simply add these to your `config/environment.js`:

```
ENV.emblemOptions {
  blueprints: false
}
```


## Ember-CLI support

  * Versions `0.1.x`: supported
  * Versions `0.2.x`: supported
