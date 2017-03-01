import ember          from 'ember'
import session        from 'ember-simple-auth/services/session'

initializer = 
  name:       'totem-simple-auth-current-user'

  initialize: (app) ->

    session.reopen
      totem_scope:      ember.inject.service()
      user:             ember.computed.reads 'totem_scope.current_user'
      is_original_user: ember.computed.bool  'secure.original_user'
      can_switch_user:  ember.computed.bool  'secure.switch_user'

      get_token: -> @get('data.authenticated.token')

export default initializer
