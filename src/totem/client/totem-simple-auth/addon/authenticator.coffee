import ember          from 'ember'
import ns             from 'totem/ns'
import config         from 'totem-config/config'
import ajax           from 'totem/ajax'
import util           from 'totem/util'
import totem_scope    from 'totem/scope'
import totem_cache    from 'totem/cache'
import totem_messages from 'totem-messages/messages'
import base           from 'ember-simple-auth/authenticators/base'

# ### TODO: Fix for using the cookie store ###

export default base.extend

  restore: (data) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless (data.token and data.email and data.user_id)

      # Server call to validate the users credentials when a page is refreshed
      # or a browser is opened that was prevously signed in by a user.
      #
      # Performing this in the restore function, allows gracefully rejecting the restore and
      # reloading the application back to the sign in page.
      # Otherwise, if just resolve, the first server call (typically show user) will fail
      # if the session is invalid (e.g. timed out).
      #
      # The credentials (user token, email and user record -> not password) are stored in
      # the browser's local storage and to clear them, the user must 'sign out'.

      # When 'restore' is called, the ember-data store is not intialized yet, so cannot make
      # a store/model request so need the full validate user url.

      validate_user_url = config.simple_auth and config.simple_auth.validate_user_url
      return reject() unless validate_user_url

      if util.starts_with(validate_user_url, 'http')
        url = validate_user_url
      else
        url = ajax.adapter_host()
        return reject() unless url
        url += '/'  unless ( util.ends_with(url, '/') or util.starts_with(validate_user_url, '/') )
        url += validate_user_url

      query =
        url:  url
        data: {user_id: data.user_id}
        beforeSend: (jqXHR) =>
          # Simulate the authorizer's jquery Prefilter by adding the Authorization header
          # with the token and email values (e.g. simple-auth-devise authorizer).
          auth = 'token' + '="' + data.token + '", ' + 'email' + '="' + data.email + '"'
          jqXHR.setRequestHeader('Authorization', 'Token ' + auth)
        success: (payload) =>
          user = @set_current_user(payload)
          return reject("totem_simple_auth validate user is blank") if ember.isBlank(user)
          resolve(data)
        error: (error) =>
          reject()
      ember.$.ajax(query)

  authenticate: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      totem_messages.clear_all()
      local_store = @get_local_store()
      return reject('totem_simple_auth authenticate local store is blank.') unless local_store
      local_store.set('isAuthenticated', false) # Without this, a new window will not trigger the redirect after route.

      query =
        model:        ns.to_p('user')
        verb:         'post'
        action:       'sign_in'
        data:         options
        skip_message: true

      ajax.object(query).then (payload) =>
        user = @set_current_user(payload)
        return reject("totem_simple_auth authenticate user is blank") if ember.isBlank(user)
        resolve
          token:            payload.token
          email:            user.get('email')
          user_id:          user.get('id')
          # for switch user capability:
          switch_user:      false
          original_user:    true
          original_user_id: user.get('id')
      , (error) =>
        reject(error)

  set_current_user: (payload) ->
    return null if ember.isBlank(payload)
    data = payload.data
    return null unless (util.is_hash(data) and data.type == ns.to_p('user'))
    user = totem_cache.push_payload_and_return_data_record(payload)
    return null if ember.isBlank(user)
    console.info "authenticated user", user
    totem_scope.set_current_user(user)
    user

  invalidate: (data) ->
    console.warn 'authenticator invalidate', data
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        model:        ns.to_p('user')
        verb:         'post'
        action:       'sign_out'
        skip_message: true
      ajax.object(query).then (payload) =>
        resolve()
      , (error) =>
        resolve()  # if the server returns an error, still sign out the ember user to clear the stores e.g. resolve not reject

  get_local_store: ->
    instance = ajax.get_instance()
    return null if ember.isBlank(instance)
    instance.lookup('session-store:application')
