import ember from 'ember'

erequire = ember.__loader.require
ncm      = erequire('ember-htmlbars/node-managers/component-node-manager').default

# When a routeable engine mounts a routeless engine, the routeless engine's component life-cycle hooks
# are not called.  Ember performs a 'revalidate' only on the top level views to perform the 'dispatchLifecycleHooks.
# However, the life-cycle hooks have been added to nested views and are never performed.
# This adds the 'didInsertElement' life-cycle hook for the component's top-level view (e.g. ownerView).
export default ->
  original_render = ncm.prototype.render
  ncm.prototype.render = (_env, visitor) ->
    component = @component
    original_render.call(@, _env, visitor)
    if _env.lifecycleHooks.length > 0 and component._state == 'hasElement'
      owner_view = component.ownerView
      owner_view._env.lifecycleHooks.push({ type: 'didInsertElement', view: component })
    # Originally tried the below, but the 'didInsertElement' hook was called to early and the component was not actually in the DOM yet:
    # _env.renderer.dispatchLifecycleHooks(_env) if _env.lifecycleHooks.length > 0 and component._state == 'hasElement'
