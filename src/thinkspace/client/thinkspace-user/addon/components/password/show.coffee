import ember           from 'ember'
import ns              from 'totem/ns'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  password:              null
  password_confirmation: null

  # # Events
  init_base: ->
    @set_changeset()

  set_changeset: ->
    model = @get('model')
    changeset = totem_changeset.create model,
      password:              [
        totem_changeset.vpresence(presence: true, message: 'You must enter a password confirmation'),
        totem_changeset.vlength(min: 8, message: 'Your password must be at least 8 characters long')
      ]
      password_confirmation: [
        totem_changeset.vpresence(presence: true, message: 'You must enter a password confirmation'),
        totem_changeset.vconfirmation(on: 'password', message: 'Your password confirmation must match the password')
      ]
    @set('changeset', changeset)

  actions:
    submit: ->
      changeset = @get('changeset')
      changeset.validate().then =>
        if changeset.get('is_valid')
          changeset.save().then =>
            @get('thinkspace').transition_to_route('users.password.success')
          , (error) =>
            @get('thinkspace').transition_to_route('users.password.fail')