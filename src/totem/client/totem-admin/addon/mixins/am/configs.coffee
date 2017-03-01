import ember  from 'ember'
import util   from 'totem/util'

export default ember.Mixin.create

  get_config_engines: -> 
    configs = util.hash_values(@tc.module_configs).sortBy 'module_prefix'
    engines = []
    for config in configs
      hash                      = {}
      hash.name                 = config.module_prefix
      hash.add_engines          = (config.add_engines or []).sortBy('engine')
      engine                    = config.engine or {}
      hash.external_routes      = (engine.external_routes or []).sort()
      hash.services             = engine.services
      hash.services             = ['none'] if ember.isBlank(hash.services) and ember.isArray(hash.services)
      hash.services             = hash.services.sort() if ember.isArray(hash.services)
      hash.sort_name            = hash.name.toLowerCase()
      hash.sort_services        = if ember.isArray(hash.services) then hash.services.join() else ''
      hash.sort_external_routes = hash.external_routes.join()
      hash.sort_add_engines     = hash.add_engines.mapBy('engine').sort().join()
      engines.push(hash)
    engines

  get_default_services: -> @te.get_app_services().sort()

  get_config_routes: ->
    routes = []
    for name, options of @tr.config_routes
      hash           = {}
      hash.name      = name or ''
      hash.path      = options.path or ''
      hash.sort_name = hash.name.toLowerCase()
      hash.sort_path = hash.path.toLowerCase()
      routes.push(hash)
    routes

  get_config_router_mounts: ->
    mounts        = []
    router_mounts = @tc.router_mounts.sortBy 'engine'
    for mount in router_mounts
      hash             = {}
      hash.engine      = mount.engine
      hash.as          = mount.args.as or ''
      hash.under       = mount.args.under or ''
      hash.path        = mount.args.path
      hash.sort_engine = hash.engine.toLowerCase()
      hash.sort_as     = hash.as.toLowerCase()
      hash.sort_under  = hash.under.toLowerCase()
      @add_mount_route_path(hash)
      mounts.push(hash)
    mounts

  add_mount_route_path: (hash) ->
    route = []
    path  = []
    if ember.isPresent(hash.under)
      route.push hash.under
      route_path = (@tr.config_routes[hash.under] or {}).path or '/'
      path.push(route_path) 
      path.push hash.path or hash.as
    else
      path.push hash.path or "/#{hash.as}"
    route.push hash.as
    hash.route      = route.join('.')
    hash.sort_route = hash.route.toLowerCase()
    hash.path       = path.join('/')
    hash.sort_path  = hash.path.toLowerCase()
