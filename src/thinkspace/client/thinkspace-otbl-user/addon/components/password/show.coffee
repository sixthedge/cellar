import ember from 'ember'
import ns         from 'totem/ns'
import base  from 'thinkspace-base/components/base'

# TODO: Add validation

export default base.extend
  layoutName: 'thinkspace/common/user/password/show'

  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'shared', 'loader'

  password: null
  password_confirmation: null

  password_confirmation_errors: ember.computed 'password', 'password_confirmation', ->
    return ['Passwords must match'] unless @get('password') == @get('password_confirmation')
    return []

  actions:
    submit: ->
      return unless @get('isValid') and ember.isEmpty(@get('password_confirmation_errors'))
      model = @get('model')
      model.set 'password', @get('password')
      model.save().then =>
        @sendAction 'goto_users_password_success'
      , (error) =>
        @sendAction 'goto_users_password_fail', error

  validations:
    password:
      length: {minimum: 8, messages: {tooShort: "Password needs to be at least 8 characters long"}}
