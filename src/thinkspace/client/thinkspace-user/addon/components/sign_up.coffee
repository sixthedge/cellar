import ember from 'ember'

export default ember.Component.extend

  authenticating: false

  invitation_present: ember.computed.notEmpty 'query_params.token'
  provided_token:     ember.computed.reads 'query_params.token'
  provided_invitable: ember.computed.reads 'query_params.invitable'

  actions:

    submit: ->
      model = @get('model')
      @set 'authenticating', true
      model.save().then (response) =>
        @set 'authenticating', false
        @sendAction 'goto_users_password_confirmation'

    sign_in_transition: (invitable, email) ->
      @transitionToRoute 'sign_in', {queryParams: {invitable: invitable, email: email, refer: 'signup'}}


# import ember from 'ember'
# import totem_changeset from 'totem/changeset'

# export default ember.Component.extend
#   tagName: ''

#   session: ember.inject.service()

#   init: ->
#     @_super(arguments...)
#     @set_changeset()

#   authenticator: 'authenticator:totem'
#   invitable:     null
#   refer:         null

#   invitation_present:   ember.computed.notEmpty 'invitable'
#   referred_from_signup: ember.computed.equal 'refer', 'signup'

#   didInsertElement: -> $('form input').first().select()

#   set_changeset: ->
#     model     = ember.Object.create(email: null, password: null, credential_error: null)
#     vpresence = totem_changeset.vpresence(presence: true)
#     @set 'changeset', totem_changeset.create model,
#       email:    [totem_changeset.vpresence(presence: true, message: 'You must enter an email address'), totem_changeset.vemail()]
#       password: [totem_changeset.vpresence(presence: true, message: 'You must enter a password')]

#   actions:

#     submit: ->
#       changeset = @get('changeset')
#       changeset.validate().then =>
#         unless changeset.get('is_valid')
#           changeset.first_error_on()
#           changeset.show_errors_on()
#           return
#         @set 'authenticating', true
#         data = {identification: changeset.get('email'), password: changeset.get('password')}
#         changeset.set 'password', null
#         @get('session').authenticate(@get('authenticator'), data).then =>
#           @set 'authenticating', false
#           @totem_messages.info "Sign in successful!"
#         , (error) =>
#           changeset.show_errors_off()
#           @set 'authenticating', false
#           message = error.responseText or 'Email or password incorrect'
#           @totem_messages.error message
