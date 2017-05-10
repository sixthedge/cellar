import ember from 'ember'

# Override the ember-engine link-to-external to set the external link
# when the owner.mountPoint is blank (e.g. a routeless engine).
# 'willRender' replaces the targetRouteName with with actual route
#  e.g. parent engine has:
#    external_routes: {home: 'spaces.index'} #=> willRender replaces 'home' with 'spaces.index'.
export default ->
  ember.LinkComponent.reopen
    willRender: () ->
      @_super(arguments...)
      owner = ember.getOwner(@)
      return if owner.mountPoint
      if owner._externalRoutes
        targetRouteName = ember.get(@, 'targetRouteName')
        return unless targetRouteName
        externalRoute = owner._getExternalRoute(targetRouteName)
        ember.set(@, 'targetRouteName', externalRoute) if externalRoute
