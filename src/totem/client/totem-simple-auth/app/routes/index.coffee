import ember  from 'ember'
import config from 'totem-config/config'
import m_unauth_route from 'ember-simple-auth/mixins/unauthenticated-route-mixin'

export default ember.Route.extend m_unauth_route,

  # The ember-simple-auth 'unauthenticated-route-mixin' adds a beforeModel hook.
  # If the session is already authenticated, transitions to the simple
  #   tranistionTo(simple_auth_config.routeIfAlreadyAuthenticated)
  # The 'beforeModel' hook is run before the 'redirect'.

  redirect: ->
    route = (config.simple_auth or {}).login_route or 'users.sign_in'
    puts "ARE WE HERE IN REDIRECT???"
    @transitionTo route
