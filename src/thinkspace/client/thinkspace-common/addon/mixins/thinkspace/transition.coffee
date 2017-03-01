import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import totem_messages from 'totem-messages/messages'
import totem_scope    from 'totem/scope'

export default ember.Mixin.create

  transition_to_current_space:      (route='show', qparams={}) ->  @transition_to_space(@get_current_space(), route, qparams)
  transition_to_current_assignment: (route='show', qparams={}) ->  @transition_to_assignment(@get_current_assignment(), route, qparams)
  transition_to_current_phase:      (route='show', qparams={}) ->  @transition_to_phase(@get_current_phase(), route, qparams)

  transition_to_space: (space, route='show', qparams={})->
    return if ember.isBlank(space)
    @set_current_models(space: space).then =>
      route = "spaces.#{route}"
      @transition_to_route(route, space, @get_transition_query_params(qparams))

  transition_to_assignment: (assignment, route='show', qparams={})->
    return if ember.isBlank(assignment)
    @set_current_models(assignment: assignment).then =>
      route = "cases.#{route}"
      @transition_to_route(route, assignment, @get_transition_query_params(qparams))

  transition_to_phase: (phase, route='show', qparams={}) ->
    return unless ember.isPresent(phase)
    @set_current_models(phase: phase).then =>
      assignment = @get_current_assignment()
      return if ember.isBlank(assignment)
      route = "phases.#{route}"
      @transition_to_route(route, assignment, phase, @get_transition_query_params(qparams))

  transition_to_model_route: (model, route='show', qparams={}) ->
    return if ember.isBlank(model)
    model_name = totem_scope.record_model_name(model)
    switch model_name
      when ns.to_p('space')      then @transition_to_space(model, route, qparams)
      when ns.to_p('assignment') then @transition_to_assignment(model, route, qparams)
      when ns.to_p('phase')      then @transition_to_phase(model, route, qparams)

  transition_to_route: (route, args...) ->
    return if ember.isBlank(route)
    transition_route = @get_transition_route()
    return if ember.isBlank(transition_route)
    args.pop() if ember.isBlank(args.get('lastObject')) # remove query params if null
    transition_route.transitionTo route, args...

  get_transition_route: -> totem_messages.get_app_route()

  get_transition_query_params: (qparams) ->
    if util.is_hash(qparams) and util.has_keys(qparams)
      if util.has_key(qparams, 'queryParams') then qparams else {queryParams: qparams}
    else
      null
