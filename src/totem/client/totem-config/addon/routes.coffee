import ember from 'ember'
import util  from 'totem/util'
import tc    from 'totem-config/configs'

class TotemRoutes

  constructor: ->
    @engine_mounts = {}
    @config_routes = {}
    @root_routes   = {}
    @populate_routes()

  # ###
  # ### Populate from Configs.
  # ###

  populate_routes: ->
    @populate_config_routes()
    @populate_config_mounts()

  populate_config_routes: ->
    routes = tc.collect_by('routes')
    return if ember.isBlank(routes)
    paths = []
    for hash in routes
      @error "Route definition must be a hash.", hash unless util.is_hash(hash)
      for name, options of hash
        @error "Route name must be a string.", hash unless util.is_string(name)
        @error "Route name '#{name}' options must be a hash.", hash unless util.is_hash(options)
        @error "Route name '#{name}' is a duplicate.", hash if ember.isPresent(@config_routes[name])
        path = options.path = (options.path or "/#{name}")
        @error "Route option path must be a string.", hash unless util.is_string(path)
        @error "Route option path '#{path}' is a duplicate.", hash if paths.includes(path)
        paths.push(path)
        @config_routes[name] = options

  populate_config_mounts: ->
    mounts = tc.get_router_mounts()
    return if ember.isBlank(mounts)
    engine_mount_as    = []
    engine_mount_paths = []
    for mount in mounts
      @error "Mount is not a hash.", mount unless util.is_hash(mount)
      mod    = mount.module
      engine = mount.engine
      args   = mount.args
      @error "Module '#{mod}' engine mount name is not a string.", mount    unless util.is_string(engine)
      @error "Module '#{mod}' engine mount args is not a hash.", mount      unless util.is_hash(args)
      @error "Module '#{mod}' engine mount is a duplicate.", mount          if ember.isPresent(@engine_mounts[engine])
      as = args.as
      @error "Module '#{mod}' engine mount args 'as' key is blank.", mount    if ember.isBlank(as)
      @error "Module '#{mod}' engine mount as '#{as}' is a duplicate.", mount if engine_mount_as.includes(as)
      path = args.path or as
      @error "Module '#{mod}' engine mount path '#{path}' is a duplicate.", mount  if engine_mount_paths.includes(path)
      under = args.under
      @error "Module '#{mod}' engine mount under route must be a string.", mount  if ember.isPresent(under) and not util.is_string(under)
      @engine_mounts[engine] = args
      engine_mount_as.push(as)       # for dup check
      engine_mount_paths.push(path)  # for dup check

  # ###
  # ### Map.
  # ###

  # ### Map does not return any value but generates the routes based
  # ### on the Route map argument (the app-router) e.g. Router.map -> totem_routes.map(@).
  map: (rmap) ->
    @map_root_routes(rmap)
    @map_engine_mounts(rmap)

  map_engine_mounts: (rmap) ->
    for engine, hash of @engine_mounts
      under = hash.under
      if ember.isPresent(under)
        map = @root_routes[under]
        @error "Engine '#{engine}' mount under route '#{under}' does not exist.", hash  if ember.isBlank(map)
        map.mount engine, hash
      else
        rmap.mount engine, hash

  map_root_routes: (rmap) ->
    for name, options of @config_routes
      @map_root_route(rmap, name, options)

  map_root_route: (rmap, name, options) ->
    _this = @
    rmap.route name, options, ->
      _this.root_routes[name] = @

  error: -> util.error(@, arguments...)

  toString: -> 'TotemRoutes'

export default new TotemRoutes
