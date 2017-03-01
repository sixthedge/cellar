import ember from 'ember'
import util  from 'totem/util'
import tc    from 'totem-config/configs'

class TotemMixins

  constructor: ->
    @target_cache  = {}
    @mixin_cache   = {}
    @target_mixins = {}
    @show_warnings = true

  process: ->
    config_mixins = tc.collect_by('mixins')
    return if ember.isBlank(config_mixins)
    config_mixins = util.flatten_array(config_mixins)
    return if ember.isBlank(config_mixins)
    for hash in config_mixins
      @error "Config mixins must be a hash.", hash unless util.is_hash(hash)
      targets = hash.target
      mixins  = hash.mixin
      @error "Config mixins must include a 'target' property.", hash if ember.isBlank(targets)
      @error "Config mixins must include a 'mixin' property.", hash  if ember.isBlank(mixins)
      for target in ember.makeArray(targets)
        for mixin in ember.makeArray(mixins)
          @add(target, mixin, set: hash.set)

  # ###
  # ### Public Methods.
  # ###

  add:    (target_paths, mixin_paths, options={}) -> @add_mixins(target_paths, mixin_paths, options)
  add_to: (mixin_paths, target_paths, options={}) -> @add_mixins(target_paths, mixin_paths, options)

  turn_warnings_on:  -> @show_warnings = true
  turn_warnings_off: -> @show_warnings = false

  app_path:       (path) -> util.app_path(path)
  app_mixin_path: (path) -> @app_path "mixins/#{path}"

  # ###
  # ### Internal Methods.
  # ###

  add_mixins: (target_paths, mixin_paths, options) ->
    @error "must pass 'target paths' to add mixins [#{@stringify(target_paths)}]."  if ember.isBlank(target_paths)
    @error "must pass 'mixin paths' to add mixins [#{@stringify(mixin_paths)}]."    if ember.isBlank(mixin_paths)
    for target_path in ember.makeArray(target_paths)
      for mixin_path in ember.makeArray(mixin_paths)
        @add_mixin(target_path, mixin_path, options)

  add_mixin: (target_path, mixin_path, options) ->
    @error "'target_path' is blank or not a string [#{@stringify(target_path)}]."  unless @valid_path(target_path)
    @error "'mixin_path' is blank or not a string [#{@stringify(mixin_path)}]."  unless @valid_path(mixin_path)
    @error "'options' is not a hash [#{@stringify(options)}]."  unless util.is_hash(options)
    return if @target_has_mixin(target_path, mixin_path)
    target = @require_target(target_path)
    @error "target at path '#{path}' is invalid -- a target must be a class or mixin.'"  unless @valid_target(target)
    mixin = @require_mixin(mixin_path)
    @error "mixin at path '#{mixin_path}' is not a mixin."  unless @is_mixin(mixin)
    set_props = options.set or null
    if ember.isPresent(set_props)
      @error "mixin at path '#{mixin_path}' set properties is not a hash.", set_props, options  unless util.is_hash(set_props)
      prop_mixin = ember.Mixin.create(set_props)
      target.reopen(mixin, prop_mixin)
    else
      target.reopen(mixin)

  target_has_mixin: (target_path, mixin_path) ->
    mixins = (@target_mixins[target_path] ?= [])
    if mixins.includes(mixin_path)
      @warn "'#{target_path}' has a duplicate mixin request for '#{mixin_path}'.  Ignoring."
      true
    else
      mixins.push(mixin_path)
      false

  require_target: (path) ->
    target = @target_cache[path]
    return target if target
    target = @require_module(path)
    @error "target module at path '#{path}' not found."  unless target
    @target_cache[path] = target
    target

  require_mixin: (path) ->
    mixin = @mixin_cache[path]
    return mixin if mixin
    mixin = @require_module(path)
    @error "mixin module at path '#{path}' not found."  unless mixin
    @mixin_cache[path] = mixin
    mixin

  require_module: (path) ->
    mod = util.require_module(path)  # first try without app prefix e.g. in the addon folder
    return mod if mod
    app_path = @app_path(path)
    util.require_module(app_path)    # second (and last) try with app prefix e.g. orchid/

  valid_path:   (obj) -> obj and typeof(obj) == 'string'
  valid_target: (obj) -> obj and (obj.isClass or @is_mixin(obj))
  is_mixin:     (obj) -> obj and obj instanceof ember.Mixin

  # ###
  # ### Warnings/Errors.
  # ###

  warn:  -> util.warn(@, arguments...)
  error: -> util.error(@, arguments...)

  stringify: (obj) -> util.stringify(obj)

  toString: -> 'TotemMixins'

export default new TotemMixins
