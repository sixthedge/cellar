import ember from 'ember'
import totem_changeset from 'totem/changeset'

export default ember.Component.extend
  tagName: ''

  session: ember.inject.service()

  init: ->
    @_super(arguments...)
    @set_changeset()

  authenticator: 'authenticator:totem'

  invitation_present:   ember.computed.notEmpty 'query_params.invitable'
  referred_from_signup: ember.computed.equal    'query_params.refer', 'signup'

  didInsertElement: -> $('form input').first().select()

  set_changeset: ->
    mock_model = ember.Object.create(email: null, password: null, credential_error: null)
    vpresence  = totem_changeset.vpresence(presence: true)
    @set 'changeset', totem_changeset.create mock_model,
      email:    [totem_changeset.vpresence(presence: true, message: 'You must enter an email address'), totem_changeset.vemail()]
      password: [totem_changeset.vpresence(presence: true, message: 'You must enter a password')]

  actions:

    submit: ->
      changeset = @get('changeset')
      changeset.validate().then =>
        unless changeset.get('is_valid')
          changeset.first_error_on()
          changeset.show_errors_on()
          return
        @set 'authenticating', true
        data = {identification: changeset.get('email'), password: changeset.get('password')}
        changeset.set 'password', null
        @get('session').authenticate(@get('authenticator'), data).then =>
          @set 'authenticating', false
          @totem_messages.info "Sign in successful!"
        , (error) =>
          changeset.show_errors_off()
          @set 'authenticating', false
          message = error.responseText or 'Email or password incorrect'
          @totem_messages.error message
