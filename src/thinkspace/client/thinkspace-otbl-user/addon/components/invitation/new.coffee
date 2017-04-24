import ember      from 'ember'
import ns         from 'totem/ns'
import config     from 'totem-config/config'
import ajax       from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

# TODO: Add validation

export default base.extend
  tagName: ''

  friendly_role:  ember.computed 'friendly_roles', ->  @get('friendly_roles.firstObject')
  friendly_roles: ember.computed ->
    roles_map = config.roles_map
    console.error "Could not find roles map in config, cannot process space_user." unless ember.isPresent(roles_map)
    roles     = []
    for role, friendly of roles_map
      roles.pushObject(friendly)
    roles
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'

  is_sending:           false
  show_errors:          false
  email:                ''
  email_input_class:    'ts-invitation-new_input-email'
  email_input_selector: ember.computed -> $(".#{@get('email_input_class')}").children('input')
  reveal_errors:        ember.observer 'email', -> @set('show_errors', true) unless @get('show_errors')
  focus_email_input:    -> @get('email_input_selector').focus()
  select_email_input:   -> @get('email_input_selector').select()


  get_role: (friendly_role) ->
    roles_map = config.roles_map
    console.error "Could not find roles map in config, cannot process space_user." unless ember.isPresent(roles_map)
    name      = null
    for role, friendly of roles_map
      name = role if ember.isEqual(friendly.toLowerCase(), friendly_role.toLowerCase())
    console.error "Could not find role for [#{friendly_role}] in config.roles_map [#{roles_map}]." unless ember.isPresent(name)
    name

  didInsertElement: -> ember.run.schedule 'afterRender', => @focus_email_input()


  actions:

    send: ->
      unless ember.isEmpty(@get('errors.email'))
        @select_email_input()
        return

      invitable = @get('invitable')
      email     = @get('email')
      role      = @get_role(@get('friendly_role'))
      options   =
        verb:   'PUT'
        action: 'invite'
        model:  invitable
        id:     invitable.get('id')
        data:   { email: email, role: role}

      @set 'is_sending', true

      ajax.object(options).then (payload) =>
        user       = ajax.normalize_and_push_payload('user', payload).get('firstObject')
        space_user = ajax.normalize_and_push_payload('space_user', payload).get('firstObject')
        space_user.set 'user', user
        @totem_messages.api_success source: @, model: user, action: 'create', i18n_path: ns.to_o('invitation', 'save')
        @set 'email', ''
        @set 'show_errors', false
        @set 'is_sending', false
        ember.run.schedule 'afterRender', => @focus_email_input()
      , (error) =>
        @set 'is_sending', false
        @totem_messages.api_falure source: @, model: user, action: 'create'
        ember.run.schedule 'afterRender', => @select_email_input()

    cancel: -> @sendAction 'cancel'

  validations:
    email:
      format: {with: /\S+@\S+/, message: "Must be a valid email"}
