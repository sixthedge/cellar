import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import te    from 'totem-engines/engines'

export default base.extend
  tagName:   ''

  init_base: ->
    @engines = null
    @get('addons').reset_dock()  if @reset_dock == true
    @set_route_addons()

  set_route_addons: (top_pocket_done) ->
    owner = ember.getOwner(@)
    return if ember.isBlank(owner)
    current_engine = owner.get('base.modulePrefix')
    return if ember.isBlank(current_engine)
    app_route     = @totem_messages.get_app_route()
    current_route = app_route.get('router.currentRouteName')
    return if ember.isBlank(current_route)
    all_addons = te.get_dock_addons(current_engine)
    return if ember.isBlank(all_addons)
    engines = {}
    for engine, hash of all_addons
      engines[engine] = true if hash[@pocket] and hash.routes.includes(current_route)
    @set 'engines', engines
