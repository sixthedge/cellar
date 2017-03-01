# Find modules in window.requirejs.entries.

class TotemConfigFindModules

  constructor: -> @module_names = null

  all: -> @module_names ?= Object.keys(window.requirejs.entries)

  filter_by: (regex) -> @all().filter (mod) -> mod.match(regex) and !mod.match(/\/tests\//)

  factory: (container, type, path) -> container.__container__.lookupFactory("#{type}:#{path}")

  get_regex: (dir, modname) ->
    new RegExp "\/#{dir}\/.*#{modname}$"

  toString: -> 'TotemConfigFindModules'

export default new TotemConfigFindModules
