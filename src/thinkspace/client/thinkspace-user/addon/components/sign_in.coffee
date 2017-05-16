import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  authenticator: 'authenticator:totem'

  # # Events
  init: ->
    @_super(arguments...)
    @set_changeset()

  didInsertElement: -> $('form input').first().select()

  # # Helpers
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
        @set_loading('authenticating')
        data = {identification: changeset.get('email'), password: changeset.get('password')}
        changeset.set 'password', null
        @get('session').authenticate(@get('authenticator'), data).then =>
          @reset_loading('authenticating')
          @totem_messages.info "You're signed in!"
        , (error) =>
          changeset.show_errors_off()
          @reset_loading('authenticating')
          message = error.responseText or 'Email or password incorrect'
          @totem_messages.error message
