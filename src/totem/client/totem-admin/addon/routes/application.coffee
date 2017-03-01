import ember from 'ember'
import ajax  from 'totem/ajax'
import auth  from 'totem-simple-auth/mixins/authenticated-route-mixin'

export default ember.Route.extend auth,

  beforeModel: (transition) ->
    @_super(arguments...)
    session = @get('session')
    return unless session.get('isAuthenticated')
    session.set 'can_totem_admin', false
    current_user = session.get('user')
    @if_superuser(current_user).then =>
      session.set 'can_totem_admin', true
    , (error) =>
      transition.abort()
      @transitionToExternal('login')

  if_superuser: (current_user) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() if ember.isBlank(current_user)
      query        =
        verb:   'post'
        action: 'is_superuser'
        model:  current_user
        id:     current_user.get('id')
      ajax.object(query).then =>
        resolve()
      , (error) =>
        reject()
