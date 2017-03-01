import ember          from 'ember'
import ns             from 'totem/ns'
import config         from 'totem-config/config'
import ajax           from 'totem/ajax'
import totem_scope    from 'totem/scope'
import base           from 'totem-simple-auth/authenticator'

export default base.extend

  # ###
  # ### Restore Switch User e.g. page reload.
  # ###

  restore: (data) ->
    console.warn 'switch user authenticator restore', data, ajax.adapter_host()
    new ember.RSVP.Promise (resolve, reject) =>
      if data.user_id == data.original_user_id
        data.authenticator = 'authenticator:totem'  # if switching back to original user, switch back to original authenticator
      else
        return reject('Invalid url')  unless @is_valid_url()
      @_super(data).then (data) =>
        resolve(data)
      , (error) =>
        reject(error)

  # ###
  # ### Valid Url.
  # ###

  get_switch_user_whitelist_regexps: ->
    whitelist = (config.simple_auth and config.simple_auth.switch_user_whitelist_regexps) or []
    ember.makeArray(whitelist)

  # Be sure to double-escape metacharacters (\\) in the regexp string e.g. '/spaces/\\d+'
  # All regexp matches use the 'ignore-case' modifier.
  #
  is_valid_url: ->
    target = (window.location.pathname or '').trim()
    return false if ember.isBlank(target)
    valid_url = @get_switch_user_whitelist_regexps().find (regex) => target.match(RegExp(regex, 'i'))
    ember.isPresent(valid_url)

  # ###
  # ### Authticate Switch User.
  # ###

  authenticate: (session, data={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      current_user = session.get('user')
      return reject('No session user.')  if ember.isBlank(current_user)
      original_user_id = session.get('secure.original_user_id')
      query =
        model:        current_user
        id:           current_user.get('id')
        verb:         'post'
        action:       'switch'
        data:         data
        skip_message: true
      ajax.object(query).then (payload) =>
        store   = @get_store()
        type    = ns.to_p('user')
        user    = store.push(type, store.normalize(type, payload[type]))
        user_id = user.get('id')
        totem_scope.ownerable(user)
        totem_scope.set_current_user(user)
        data =
          token:            payload.token
          email:            user.get('email')
          user_id:          user_id
          # for switch user capability:
          switch_user:      true
          original_user_id: original_user_id
          original_user:    (original_user_id == user_id)
        resolve(data)
      , (error) =>
        reject(error)
