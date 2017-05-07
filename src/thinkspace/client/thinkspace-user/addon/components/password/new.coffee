import ember           from 'ember'
import ns              from 'totem/ns'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  model:      null # Set by the route, instance of PasswordReset
  has_errors: false

  # # Events
  init_base: ->
    @set_changeset()

  set_changeset: ->
    model = @get('model')
    changeset = totem_changeset.create model,
      email: [
        totem_changeset.vpresence(presence: true, message: 'You must enter an email'),
        totem_changeset.vformat(type: 'email', message: 'You must enter a valid email')
      ]
    @set('changeset', changeset)

  # # Helpers
  set_has_errors: -> @set('has_errors', true)
  reset_has_errors: -> @set('has_errors', false)

  actions:
    submit: ->
      model     = @get('model')
      changeset = @get('changeset')
      changeset.validate().then =>
        if changeset.get('is_valid')
          @set_loading('authenticating')
          changeset.save().then =>
            @reset_has_errors()
            @reset_loading('authenticating')
            @get('thinkspace').transition_to_route('users.password.confirmation')
          , (error) =>
            @reset_loading('authenticating')
            @set_has_errors()
        else
          changeset.show_errors_on()