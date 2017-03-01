import ember from 'ember'
erequire        = ember.__loader.require
outlet          = erequire('ember-htmlbars/keywords/outlet').default
ViewNodeManager = erequire('ember-htmlbars/node-managers/view-node-manager').default

# Implements routeable components (see: ember-routeable-components-shim).

export default ->
  original_render = outlet.render
  outlet.render   = (renderNode, _env, scope, params, hash, template, inverse, visitor) ->
    env         = _env
    state       = renderNode.getState()
    owner       = env.owner
    parentView  = env.view
    outletState = state.outletState
    toRender    = outletState.render
    namespace   = owner.lookup('application:main')

    ViewClass = outletState.render.ViewClass
    owner     = env.originalOwner || owner

    if !state.hasParentOutlet and !ViewClass
      outletState.render.ViewClass = owner._lookupFactory('view:toplevel')

    name      = toRender.name
    component = owner._lookupFactory("component:#{name}")
    layout    = owner.lookup("template:components/#{name}")

    # Routable component or template not found, use original implementation.
    return original_render(arguments...) if not (component or layout)

    attrs =
      model:  Ember.get(toRender.controller, 'model')
      target: Ember.get(toRender.controller, 'target')

    # Add the query params to the component.
    attrs.query_params            = Ember.get(toRender.controller, 'target.router.state.fullQueryParams') or {}
    attrs.query_params_controller = toRender.controller

    options =
      component: component or ember.Component.extend()
      layout:    layout

    if state.manager
      state.manager.destroy()
      state.manager = null

    nodeManager   = ViewNodeManager.create(renderNode, env, attrs, options, parentView, null, null, template)
    state.manager = nodeManager

    # console.warn '=====OUTLET ENV', env
    # console.info '=====OUTLET OWNER', owner
    # console.info '=====OUTLET STATE', state
    # console.info '=====OUTLET LAYOUT', component, layout
    # console.info '=====OUTLET NODEMANAGER', nodeManager, options
    # console.info '=====OUTLET RENDER NODE', renderNode
    # console.info '=====OUTLET PARENT VIEW', parentView
    # console.info '=====OUTLET TEMPLATE', template

    nodeManager.render(env, hash, visitor)
