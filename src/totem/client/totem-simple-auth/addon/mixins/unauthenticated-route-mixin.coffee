import ember from 'ember'
import configuration from 'ember-simple-auth/configuration'

# Re-implement the ember-simple-auth mixin to handle engines.
# The 'transitionTo' is changed to 'transitionToExternal'.

export default Ember.Mixin.create

  session: ember.inject.service()

   # If `beforeModel` is overridden in a route that uses this mixin, the route's
   # implementation must call '@_super(arguments...)' so that the mixin's
   # `beforeModel` method is actually executed.

  beforeModel: (transition) ->
    if @get('session.isAuthenticated')
      transition.abort()
      ember.assert('The route configured as Configuration.routeIfAlreadyAuthenticated cannot implement the UnauthenticatedRouteMixin mixin as that leads to an infinite transitioning loop!', @get('routeName') != configuration.routeIfAlreadyAuthenticated)
      @transitionToExternal(configuration.routeIfAlreadyAuthenticated)
    else
      @_super(arguments...)
