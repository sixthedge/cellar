import ember from 'ember'
import auth_config from 'ember-simple-auth/configuration'

export default ember.Route.extend
  model: (params) -> params

  actions:
    sign_in_transition: ->
      sign_in_url = auth_config.authenticationRoute
      @transitionTo sign_in_url  if sign_in_url