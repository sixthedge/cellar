import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend
  titleToken: (model) -> model.get('title')

  phase_manager: ember.inject.service()

  queryParams: {query_id: {}}

  model: (params, transition) ->
    @tc.find_record_with_message(ns.to_p('phase'), params.phase_id).then (phase) =>
      phase
    , (error) => null

  afterModel: (phase, transition) ->
    return @transitionToExternal 'spaces.index' if ember.isBlank(phase)
    @hide_loading_outlet() if ember.isEqual(@get_phase(), phase) # Hide outlet if navigating to same phase.
    @current_models().set_current_models(phase: phase).then =>
      @get('phase_manager').set_all_phase_states().then =>
        @validate_phase_state(phase, transition)

  renderTemplate: (controller, phase) -> @route_based_on_phase_state(phase)

  # deactivate: ->
  #   @_super()
  #   controller = @get 'controller'
  #   controller.reset_phase_settings()
  #   controller.reset_query_id() # query_id persists between cases, need to reset.

  # ###
  # ### Helper functions.
  # ###

  get_assignment:        -> @current_models().get_current_assignment()
  get_phase:             -> @current_models().get_current_phase()
  get_phase_manager:     -> @get 'phase_manager'
  get_phase_manager_map: -> @get 'phase_manager.map'
  show_loading_outlet:   -> @get_phase_manager().show_loading_outlet()
  hide_loading_outlet:   -> @get_phase_manager().hide_loading_outlet()

  # ###
  # ### Route on Phase State.
  # ###

  validate_phase_state: (phase, transition) ->
    assignment = @get_assignment()
    assignment.totem_data.ability.refresh().then =>
      can_update = assignment.get('can.update')
      query_id   = transition.queryParams.query_id
      @get_phase_manager().get_phase_state_for_phase(phase, query_id).then (phase_state) =>
        can_view   = if phase_state then (not phase_state.get('is_locked')) else false
        can_access = can_view or can_update
        # If the phase state is locked, redirect back to 'assignments#show' unless
        # can update the phase (e.g. gradebook)
        unless can_access
          @totem_messages.error('You cannot access a locked phase.')
          @transition_to_assignment()

  route_based_on_phase_state: (phase) ->
    can_update    = @get_assignment().get('can_update')
    phase_manager = @get_phase_manager()
    map           = @get_phase_manager_map()
    query_id      = @get('controller.query_id')
    phase_manager.get_phase_state_for_phase(phase, query_id).then (phase_state) =>
      switch
        when phase_state
          phase_manager.set_ownerable_from_phase_state(phase_state).then => @render_view()

        when map.ownerable_has_multiple_phase_states(phase)
          if can_update and phase_manager.has_active_addons()
            @render_view()
          else
            @render ns.to_p('phases', 'select_phase_state')  # note: this is NOT in the template/components folder e.g. ns.to_p not ns.to_t
            @hide_loading_outlet()

        when can_update
          @render_view()

        else
          @transition_to_assignment()

  transition_to_assignment: ->
    @hide_loading_outlet()
    @get('thinkspace').transition_to_current_assignment()

  render_view: ->
    @show_loading_outlet()
    @get_phase_manager().generate_view_with_ownerable().then =>
      @render()
      @hide_loading_outlet()
