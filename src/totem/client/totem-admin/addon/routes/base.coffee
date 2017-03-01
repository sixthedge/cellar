import ember from 'ember'
import auth  from 'totem-simple-auth/mixins/authenticated-route-mixin'

export default ember.Route.extend auth,

  beforeModel: (transition) ->
    @_super(arguments...)
    session = @get('session')
    if ember.isBlank(session) or not session.get('can_totem_admin')
      transition.abort()
      @transitionToExternal('login')
