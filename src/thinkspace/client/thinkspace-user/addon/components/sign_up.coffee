import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import config          from 'totem-config/config'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  debug:         config.autofill
  authenticator: 'authenticator:totem'

  # # Computed properties
  token:     ember.computed.reads 'query_params.token'
  email:     ember.computed.reads 'query_params.email'
  invitable: ember.computed.reads 'query_params.invitable'
  has_token: ember.computed.notEmpty 'token'

  # {"roles"=>{"student"=>true, "instructor"=>false}}

  # # Events
  init_base: ->
    @set_changeset()

  set_changeset: ->
    model = ember.Object.create(first_name: null, last_name: null, email: null, password: null)
    changeset = totem_changeset.create model,
      first_name:  [totem_changeset.vpresence(presence: true, message: 'You must enter a first name')]
      last_name:   [totem_changeset.vpresence(presence: true, message: 'You must enter a last name')]
      email:       [totem_changeset.vpresence(presence: true, message: 'You must enter an email address'), totem_changeset.vemail()]
      password:    [totem_changeset.vpresence(presence: true, message: 'You must enter a password')]
      roles:       [totem_changeset.vpresence(presence: true, message: 'You must select your role')]
    @set_debug_changeset(changeset)
    changeset.set('email', @get('email')) if @get('has_token') and @get('email')
    @set('changeset', changeset)

  set_debug_changeset: (changeset) ->
    return unless @get('debug')
    time = new Date().getTime()
    changeset.set('first_name', 'Test')
    changeset.set('last_name', time)
    changeset.set('email', "#{time}@sixthedge.com")
    changeset.set('password', 'password')

  authenticate: (user) ->
    changeset = @get('changeset')
    data      = {identification: changeset.get('email'), password: changeset.get('password')}
    @set_loading('authenticating')
    @get('session').authenticate(@get('authenticator'), data).then =>
      # Reset password values so they're not lingering.
      user.set('password', null)
      changeset.set('password', null)
      @reset_loading('authenticating')
      @totem_messages.info "Sign in successful!"
    , (error) =>
      @reset_loading('authenticating')
      changeset.show_errors_off()
      message = error.responseText or 'Email or password incorrect'
      @totem_messages.error message

  actions:
    submit: ->
      changeset = @get('changeset')
      changeset.validate().then =>
        is_valid = changeset.get('is_valid')
        if is_valid
          user = @totem_scope.get_store().createRecord ns.to_p('user'),
            first_name: changeset.get('first_name')
            last_name:  changeset.get('last_name')
            email:      changeset.get('email')
            password:   changeset.get('password')
            profile:    
              roles: changeset.get('roles')
          token = @get('token')
          user.set('token', token) if ember.isPresent(token)
          @set_loading('submitting')
          user.save().then =>
            @reset_loading('submitting')
            @authenticate(user)
          , (error) =>
            @reset_loading('submitting')
            # TODO: This currently boots them out of the application in the case of an error.
            @totem_messages.api_failure error, source: @, model: user, action: 'create'
        else
          changeset.show_errors_on()