import ember            from 'ember'
import util             from 'totem/util'
import tc               from 'totem-config/configs'
import fm               from 'totem-config/find_modules'
import Engine           from 'ember-engines/engine'
import Resolver         from 'totem-engines/resolver'
import loadInitializers from 'ember-load-initializers'

class Engines

  # ###
  # ### Class Variables and Methods.
  # ###
  @engines      = {} # if saving each engine
  @current_app  = null
  @app_services = null
  @dock_addons  = {}

  @get_dock_addons: (name) -> @dock_addons[name]

  @get_app_services = -> (@app_services and @app_services.copy()) or @set_app_services().copy()

  # Find and set the app's base services (e.g. those not namespaced or in an engine).
  # Add these services to each engine's dependencies.
  @set_app_services = ->
    srv_path = util.app_path('services')
    regex    = new RegExp "#{srv_path}\/(\\w+)$"
    mods     = fm.filter_by(regex)
    services = ['store', 'session'] # always include these services
    for mod in mods
      service = mod.match(regex).get('lastObject')
      services.push(service) if service
    @app_services = services.uniq()

  # ###
  # ### Instance Methods.
  # ###
  constructor: (@env, @options={}) ->
    @error "The constructor config must be a hash.", {@env}  unless util.is_hash(@env)
    @error "The constructor options must be a hash.", {@options} unless util.is_hash(@options)
    @engine_options    = {}
    @resolver          = Resolver
    @module_prefix     = @env.modulePrefix
    @pod_module_prefix = @env.podModulePrefix
    @set_addon_services(@options)
    @set_addon_external_routes(@options)
    @add_config_engines()

  add_config_engines: ->
    add_engines = tc.get_add_engines(@module_prefix)
    return if ember.isBlank(add_engines)
    @add_engine(hash.engine, hash.args) for hash in add_engines

  add_engine: (name, options={}) ->
    @error "Method 'add_engine' name must be a string.", {name} unless util.is_string(name)
    @error "Method 'add_engine' options must be a hash.", options unless util.is_hash(options)
    engine              = @engine_options[name.camelize()] = {}
    hash                = engine.dependencies = {}
    hash.services       = @get_options_services(options)
    hash.externalRoutes = @get_options_external_routes(options)
    @add_dock_addons(name, options)
    return @ # so can chain 'add_engine' calls

  # ###
  # ### Set the addon's engine dependencies if not added in the 'new totem_engines(config, options)'.
  # ### (e.g. not an added engine - which are provided in the "add_engine" method options).
  # ###
  set_addon_services: (options)        -> @services        = @get_addon_options_services(options)
  set_addon_external_routes: (options) -> @external_routes = @get_addon_options_external_routes(options)

  get_app: ->
    eng = ember.Application.extend
      modulePrefix:    @module_prefix
      podModulePrefix: @pod_module_prefix
      Resolver:        @resolver
      engines:         @engine_options
    Engines.current_app = @load_initializers(eng) # set the app in the class

  get_engine: ->
    eng = Engine.extend
      modulePrefix: @module_prefix
      Resolver:     @resolver
      dependencies:
        services:       @services
        externalRoutes: @external_routes
      engines: @engine_options
    @load_initializers(eng)

  # ###
  # ### Private ### #
  # ###

  app_services: -> Engines.get_app_services()

  get_addon_options_services: (options) ->
    config_options = tc.get_services(@module_prefix)
    config_options = null if ember.isBlank(util.hash_keys(config_options))
    @get_options_services(options, config_options)

  get_addon_options_external_routes: (options) ->
    engine_routes = options.external_routes or []
    @error "External routes for the addon engine dependencies must be an array.", options unless util.is_array(engine_routes)
    config_routes = tc.get_external_routes(@module_prefix) or []
    routes        = engine_routes.concat(config_routes).uniq()
    return [] if ember.isBlank(routes)
    routes

  # CAUTION when using options 'add_services' and 'except_services'.
  # Both the engine and consuming-engine must be in sync with services.
  get_options_services: (options, config_options=null) ->
    is_none         = util.is_array(options.services) and ember.isBlank(options.services)
    services        = ember.makeArray(options.services).compact()
    add_services    = ember.makeArray(options.add_services).compact()
    except_services = ember.makeArray(options.except_services).compact()
    if ember.isPresent(config_options)
      is_none         = util.is_array(config_options.services) and ember.isBlank(config_options.services)
      services        = services.concat(ember.makeArray(config_options.services).compact()).uniq()
      add_services    = add_services.concat(config_options.add_services).uniq()
      except_services = except_services.concat(config_options.except_services).uniq()
    services = @app_services() if !is_none and ember.isBlank(services) # allow 'no' services via empty array
    services.push(service) for service in add_services  if ember.isPresent(add_services)
    services = services.without(service) for service in except_services  if ember.isPresent(except_services)
    services.compact().uniq()

  get_options_external_routes: (options) ->
    routes = options.external_routes
    return {} if ember.isBlank(routes)
    @error "External routes for the addon engines: {} must be an hash.", options unless util.is_hash(routes)
    routes

  load_initializers: (eng) ->
    loadInitializers(eng, @module_prefix)
    @save_engine_instance(eng)
    eng

  save_engine_instance: (eng) ->
    return
    # @current_engine = eng  # set in this instance in the class
    # Engines.engines[@module_prefix] = eng  # save engine
    # Engines.engines[@module_prefix] = @    # save this instance

  add_dock_addons: (name, options) ->
    dock = options.dock
    return if ember.isBlank(dock)
    @error "Dock values for engine #{name} must be a hash.", {dock} unless util.is_hash(dock)
    routes = ember.makeArray(dock.routes)
    return if ember.isBlank(routes)
    dock.routes  = routes
    addons       = (Engines.dock_addons[@module_prefix] ?= {})
    addons[name] = dock

  error: -> util.error(@, arguments...)

  toString: -> 'TotemEngines'

export default Engines
