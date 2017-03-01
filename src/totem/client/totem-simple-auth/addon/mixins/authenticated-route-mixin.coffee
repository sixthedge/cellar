import ember from 'ember'
import configuration from 'ember-simple-auth/configuration'

# Re-implement the ember-simple-auth mixin to handle engines.
# The 'transitionTo' is changed to 'transitionToExternal'.

# Routes should include the totem mixin: 'totem-simple-auth/mixins/authenticated-route-mixin'.

export default Ember.Mixin.create

  session: ember.inject.service()

   # If `beforeModel` is overridden in a route that uses this mixin, the route's
   # implementation must call '@_super(arguments...)' so that the mixin's
   # `beforeModel` method is actually executed.

  beforeModel: (transition) ->
    if !@get('session.isAuthenticated')
      transition.abort()
      @set('session.attemptedTransition', transition)
      try
        @transitionToExternal(configuration.authenticationRoute)
      catch error
        console.error error
        console.warn "Error transitioning to authentication route, did you define '#{configuration.authenticationRoute}' as an external route in your engine config?"
    else
      @_super(arguments...)
