import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'
import ns              from 'totem/ns'
import authenticate    from 'thinkspace-ltiv1/mixins/authenticate'

export default base.extend authenticate,

  query_param_keys: [
    'email',
    'user_id',
    'auth_token',
    'context_title',
    'context_type',
    'resource_link_id',
    'consumer_title'
  ]

  init_base: ->
    @init_query_params()
    @set_loading 'all'
    @authenticate().then =>
      @get_model().then (model) =>
        @set 'model', model
        @reset_loading 'all'


  init_query_param: (param) ->
    value = @get_query_param(param)
    @get('lti_session').set_query_param_for_route('setup', param, value)
    @set param, value

  get_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('space')).then (spaces) =>
        @set 'spaces', spaces
        resolve(spaces)

  get_route: -> @get('container').lookup('route:setup')

  no_spaces: ember.computed.empty 'spaces'

  provider_context_type: ember.computed 'context_type', -> 
    return 'case' if @get('context_type') == 'assignment'
    return 'space'

  consumer_context_type: ember.computed 'context_type', -> 
    return 'course' if @get('context_type') == 'space'
    return 'assignment'

  actions:

    select: (space) ->
      @set 'selected_space', space

    create: ->
      space = @get('selected_space')
      model = 'thinkspace/ltiv1/context'

      params = 
        email:            @get('email')
        resource_link_id: @get('resource_link_id')
        contextable_type: ns.to_p('space')
        contextable_id:   space.get('id')

      options =
        action: 'sync'
        verb:   'POST'

      @tc.query_data(model, params, options).then (payload) =>
        @totem_messages.info "#{@get('context_title')} linked to space #{space.get('title')} successfully."
        @transition_to_context(space)
      , (error) =>
        @set_loading 'error'
