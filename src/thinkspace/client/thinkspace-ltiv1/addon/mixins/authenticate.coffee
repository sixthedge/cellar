import ember  from 'ember'
import ns     from 'totem/ns'

export default ember.Mixin.create

  authenticator: 'lti_authenticator:totem'
  lti_session:   ember.inject.service()

  init_query_params: ->
    @get('query_param_keys').forEach (key) => @init_query_param(key)


  transition_to_context: (context=null)->
    id    = @get('context_id') || context
    type  = @get('context_type')
    route = @get_route()

    return unless (ember.isPresent(context) || (ember.isPresent(id) && ember.isPresent(type) && ember.isPresent(route)))

    if ns.to_p(type) == ns.to_p('space')
      route.transitionToExternal('spaces.show', id)
    else if ns.to_p(type) == ns.to_p('assignment')
      route.transitionToExternal('cases.show', id)

  set_session_lti: -> @get('session').set('is_lti', true)

  authenticate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_loading('authenticating')

      data = 
        user_id: @get('user_id')
        email:   @get('email')
        token:   @get('auth_token')

      @set_session_lti()

      @get('session').authenticate(@get('authenticator'), data).then =>
        @reset_loading('authenticating')
        @totem_messages.info "You're logged in!"
        @transition_to_context()
        resolve()
      , (error) =>
        console.log "LTI authenticate failed with error", error
        @reset_loading('authenticating')
        @set_loading('error')
        reject()