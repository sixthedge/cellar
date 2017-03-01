import ember from 'ember'
import util  from 'totem/util'
import fm    from 'totem-config/find_modules'
import {env} from 'totem-config/config'

# Find '_config' modules in 'window.requirejs.entries', require the module and collect the contents.
class TotemConfigs

  constructor: ->
    mp = env.modulePrefix
    @error "Application modulePrefix is blank." if ember.isBlank(mp)
    @app_auto_mount     = env.app_auto_mount or true
    @module_configs     = {}
    @router_mounts      = []
    @module_configs[mp] = {app: true, module_prefix: mp, module: 'app.js', engine: 'root app', add_engines: []}
    @app_engines        = @module_configs[mp].add_engines # main app for 'mounted' engines
    @populate_contents()

  get_router_mounts: -> @router_mounts
  get_ns:            -> @collect_by('ns')
  get_query_params:  -> @collect_by('query_params')

  get_config:          (name) -> @module_configs[name] or {}
  get_config_engine:   (name) -> @get_config(name).engine or {}
  get_add_engines:     (name) -> @get_config(name).add_engines
  get_external_routes: (name) -> @get_config_engine(name).external_routes

  get_services:        (name) ->
    engine = @get_config_engine(name)
    {services: engine.services, add_services: engine.add_services, except_services: engine.except_services}

  # ###
  # ### Populate.
  # ###

  populate_contents: ->
    mod_regex = new RegExp ".*\/_config$"
    mods      = fm.filter_by(mod_regex)
    for mod in mods
      original_config = util.require_module(mod)
      @error "Module '#{mod}' is not a hash.", original_config   unless util.is_hash(original_config)
      config        = util.dup_hash(original_config)
      config.module = mod
      module_prefix = @get_module_prefix(config)
      @error "Module prefix '#{module_prefix}' is a duplicate.", config  if ember.isPresent(@module_configs[module_prefix])
      config.module_prefix = module_prefix
      @module_configs[module_prefix] = @standardize_config(config)
    console.warn @module_configs

  get_module_prefix: (config) ->
    mod = config.module
    env = config.env
    @error "Module '#{mod}' does not have an environment 'env' key.", config   unless util.is_hash(env)
    module_prefix = env.modulePrefix
    @error "Module '#{mod}' does not have a 'modulePrefix' environment key.", config   unless util.is_string(module_prefix)
    module_prefix

  # ###
  # ### Standarize Config.
  # ###

  standardize_config: (config) ->
    config.ns           = @standardize_ns(config)
    config.query_params = @standardize_query_params(config)
    config.add_engines  = @standardize_add_engines(config)
    config.engine       = @standardize_engine(config)
    util.delete_blank_hash_keys(config)
    config

  standardize_ns: (config) ->
    ns = config.ns
    return null if ember.isBlank(ns)
    @error "NS must be a hash.", config unless util.is_hash(ns)
    hash        = util.dup_hash(ns)
    hash.module = config.module
    hash

  standardize_query_params: (config) ->
    qp = config.query_params
    return null if ember.isBlank(qp)
    @error "Query params must be a hash.", config unless util.is_hash(qp)
    array = []
    for model, args of qp
      array.push {model: model, args: args, module: config.module}
    array

  standardize_add_engines: (config) ->
    add_engines = config.add_engines or config.engines
    return null if ember.isBlank(add_engines)
    engines = ember.makeArray(add_engines).compact()
    array   = []
    for engine in engines
      @error "Engines must be a string or hash.", engine unless (util.is_string(engine) or util.is_hash(engine))
      if util.is_string(engine)
        array.push {engine: engine, args: {}, module: config.module}
      else
        for k, args of engine
          @error "Engines args be a hash.", engine unless util.is_hash(args)
          array.push {engine: k, args: args, module: config.module}
    array

  # ###
  # ### Engine.
  # ###

  standardize_engine: (config) ->
    engine = config.engine
    return null if ember.isBlank(engine)
    @error "Engine value must be a hash.", engine unless util.is_hash(engine)
    external_routes = @standardize_external_routes(config, engine)
    services        = @standardize_services(config, engine)
    mount           = @standardize_mount(config, engine)
    if @app_auto_mount and ember.isPresent(mount)
      @router_mounts.push(mount)
      app_engine = @build_app_engine(config, engine)
      @app_engines.push(app_engine) if ember.isPresent(app_engine)
      config._app_engine = app_engine  # used only for debugging
      config._mount      = mount       # used only for debugging
    engine.external_routes = external_routes
    ember.merge engine, services
    util.delete_blank_hash_keys_except(engine, 'services')
    engine

  standardize_mount: (config, engine) ->
    mount = engine.mount
    return null if ember.isBlank(mount)
    switch
      when util.is_string(mount)  then mount = {as: mount}
      when util.is_hash(mount)    # use as-is
      else @error "Mount value must be a string or hash.", config
    @error "Mount must include an 'as' key." if ember.isBlank(mount.as)
    {engine: config.module_prefix, module: config.module, args: mount}

  standardize_external_routes: (config, engine) ->
    routes = engine.external_routes
    return null if ember.isBlank(routes)
    array = []
    for route in ember.makeArray(routes)
      switch
        when util.is_string(route)  then array.push(route)
        when util.is_hash(route)    then array = array.concat util.hash_keys(route)
        else @error "External routes must be a string or hash.", config
    array

  standardize_services: (config, engine) ->
    {services, add_services, except_services} = engine
    hash = {}
    services             = unless util.is_array(services)    then null else services
    hash.add_services    = if ember.isBlank(add_services)    then null else ember.makeArray(add_services)
    hash.except_services = if ember.isBlank(except_services) then null else ember.makeArray(except_services)
    if ember.isPresent(services)
      array = []
      for service in services
        switch
          when util.is_string(service)  then array.push(service)
          when util.is_hash(service)    then array.concat util.hash_keys(service)
          else @error "Services must be a string or hash.", config
      hash.services = array
    hash

  # ###
  # ### Build Engine Config for Mounted Engines.
  # ###

  # For a mounted engine, services and external-routes are hashes.
  build_app_engine: (config, engine, mount) ->
    args = {}
    ember.merge args, @standardize_app_services(config, engine)
    args.external_routes = @standardize_app_external_routes(config, engine)
    util.delete_blank_hash_keys(args)
    hash = {engine: config.module_prefix, module: config.module, args: args}
    hash

  standardize_app_external_routes: (config, engine) ->
    routes = engine.external_routes
    return null if ember.isBlank(routes)
    hash = {}
    for route in ember.makeArray(routes)
      switch
        when util.is_string(route)  then hash[route] = route
        when util.is_hash(route)    then ember.merge hash, route
        else @error "External routes must be a string or hash.", config
    hash

  standardize_app_services: (config, engine) ->
    {services, add_servicess, except_services} = engine

  # ###
  # ### Helpers.
  # ###

  collect_by: (key) ->
    contents = []
    for pkg, values of @module_configs
      val = values[key]
      contents.push(val) if ember.isPresent(val)
    contents

  error: -> util.error(@, arguments...)

  toString: -> 'TotemConfigs'

export default new TotemConfigs
