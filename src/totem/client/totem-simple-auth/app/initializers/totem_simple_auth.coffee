import authenticator             from 'totem-simple-auth/authenticator'
import lti_authenticator         from 'totem-simple-auth/lti_authenticator'
import authorizer                from 'totem-simple-auth/authorizer'
import authenticator_switch_user from 'totem-simple-auth/authenticator_switch_user'
import cookie_store              from 'totem-simple-auth/cookie_store'

initializer = 
  name:   'totem-simple-auth'

  initialize: (app) ->

    app.register('authenticator:totem', authenticator)
    app.register('lti_authenticator:totem', lti_authenticator)
    app.register('authenticator_switch_user:totem', authenticator_switch_user)
    app.register('authorizer:totem', authorizer)
    # app.register('simple-auth-session-store:totem-cookie-store', cookie_store)

export default initializer
