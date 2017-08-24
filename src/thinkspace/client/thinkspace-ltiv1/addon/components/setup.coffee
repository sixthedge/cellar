import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'
import ns              from 'totem/ns'
import authenticate    from 'thinkspace-ltiv1/mixins/authenticate'
import totem_scope     from 'totem/scope'

export default base.extend authenticate,

  # ### Properties

  context_type: 'space'

  selected_space:      null
  selected_assignment: null

  lti_session: ember.inject.service()

  query_param_keys: [
    'email',
    'user_id',
    'auth_token',
    'context_title',
    'resource_link_id',
    'resource_link_title',
    'consumer_title'
  ]

  # ### Methods

  init_base: ->
    @init_query_params()
    @set_loading 'authenticate'
    @authenticate().then =>
      @get_model().then (model) =>
        @set 'model', model
        @set_lti_redirect()
        @reset_loading 'authenticate'
    , (error) =>
      @reset_loading 'authenticate'
      @set_loading 'authenticate_error'

  init_query_param: (param) ->
    value = @get_query_param(param)
    @get('lti_session').set_query_param_for_route('setup', param, value)
    @set param, value

  set_lti_redirect:   -> @get('lti_session').set_redirect('setup')
  reset_lti_redirect: -> @get('lti_session').reset_redirect()

  get_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('space')).then (spaces) =>
        @set 'spaces', spaces
        resolve(spaces)

  get_route: -> @get('container').lookup('route:setup')

  get_assignments_for_space: (space) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_loading 'assignments'
      @tc.find_record(ns.to_p('space'), space.get('id')).then (space) =>
        assignments = space.get('assignments_due_at_asc')
        console.log "assignments:", assignments
        @set 'assignments', assignments
        @reset_loading 'assignments'
        resolve(assignments)

  # ### Computed Properties

  no_spaces:      ember.computed.empty 'spaces'
  no_assignments: ember.computed.empty 'assignments'

  provider_context_type: ember.computed 'context_type', -> 
    return 'exercise' if @get('context_type') == 'assignment'
    return 'space'

  consumer_context_type: ember.computed 'context_type', -> 
    return 'course' if @get('context_type') == 'space'
    return 'assignment'

  resource_title: ember.computed 'resource_link_title', 'context_title', ->
    return @get('resource_link_title') if @get('context_type_is_assignment')
    return @get('context_title') if @get('context_type_is_space')

  context_type_is_assignment: ember.computed.equal 'context_type', 'assignment'
  context_type_is_space:      ember.computed.equal 'context_type', 'space'

  selected_resource: ember.computed 'selected_space', 'selected_assignment', ->
    return @get('selected_assignment') if ember.isPresent(@get('selected_assignment'))
    return @get('selected_space')

  # show confirmation if they have selected a resource and the resource is the appropriate context type
  show_confirmation: ember.computed 'selected_resource', 'context_type', ->
    resource = @get('selected_resource')
    type     = @get('context_type')
    return (ember.isPresent(resource) && (totem_scope.get_record_path(resource) == ns.to_p(type)))

  # show assignments if a space is selected and the context type is an assignment
  show_assignments: ember.computed 'selected_space', 'context_type', ->
    ember.isPresent(@get('selected_space')) && (@get('context_type') == 'assignment')

  # ### Actions

  actions:

    set_context_type_space: -> @set 'context_type', 'space'

    set_context_type_assignment: -> @set 'context_type', 'assignment'

    select_space: (space) ->
      @set 'selected_space', space
      @get_assignments_for_space(space) if @get('context_type_is_assignment')

    select_assignment: (assignment) ->
      @set 'selected_assignment', assignment

    create: ->
      @set_loading 'create'
      contextable = @get('selected_resource')
      model       = 'thinkspace/ltiv1/context'

      params = 
        email:            @get('email')
        resource_link_id: @get('resource_link_id')
        contextable_type: totem_scope.get_record_path(contextable)
        contextable_id:   contextable.get('id')

      options =
        action: 'sync'
        verb:   'POST'

      @tc.query_data(model, params, options).then (payload) =>
        @totem_messages.info "#{@get('resource_title')} linked to #{@get('provider_context_type')} #{contextable.get('title')} successfully."
        @reset_loading 'create'
        @reset_lti_redirect()
        @transition_to_context(contextable)
      , (error) =>
        @set_loading 'create_error'
