import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()

  init_base: ->
    @thinkspace = @get('thinkspace')
    @pmap       = @get('phase_manager.map')
    key         = @results_key or 'inputs'
    ember.defineProperty @, 'has_values',    ember.computed.bool  "tvo.status.#{key}"
    ember.defineProperty @, 'valid_count',   ember.computed.reads "tvo.status.#{key}.results.valid"
    ember.defineProperty @, 'invalid_count', ember.computed.reads "tvo.status.#{key}.results.invalid"

  is_edit:                ember.computed.bool  'tvo.status.is_edit'
  submit_messages:        ember.computed.reads 'tvo.status.messages'
  submit_messages_title:  ember.computed.or 'tvo.status.messages_title', 'default_messages_title'
  default_messages_title: 'Please correct the following:'

  actions:
    submit: -> @tvo_status_validate().then (is_valid) => if is_valid then @phase_valid() else @phase_invalid()

  phase_valid: ->
    @submit_phase().then =>
      @totem_messages.info 'Case submitted successfully.'
      @tvo_show_errors_off()
      @transition_after_submit()
    , (error) => @phase_invalid()

  phase_invalid: -> @tvo_show_errors_on()

  submit_phase: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase = @get_phase()
      console.log "SUBMIT PHASE", phase
      query =
        id:     phase.get('id')
        model:  phase
      options =
        verb:   'PUT'
        action: 'submit'
      # return resolve() # ### TEMP FOR TESTING
      # A @tc.find_record on a phase with an action does not side load data in time and introduces a race condition.
      # => This resolves the issue (doing a pushPayload on the model needed later in the chain).
      @tc.query_action(ns.to_p('phase'), query, options).then =>
        @totem_messages.api_success source: @, model: phase, i18n_path: ns.to_o 'phase', 'submit'
        resolve()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: phase
        reject()

  transition_after_submit: ->
    phase = @get_phase()
    @pmap.find_next_phase_in_state(phase).then (next_phase) =>
      if next_phase
        next_state   = @pmap.get_current_user_selected(next_phase)
        query_params = @get_query_params(next_state)
        @thinkspace.transition_to_phase(next_phase, 'show', query_params)
      else
        @thinkspace.transition_to_current_assignment()

  # ###
  # ### Helpers.
  # ###

  get_query_params: (phase_state) -> if ember.isBlank(phase_state) or phase_state.is_mock then {query_id: 'none'} else {query_id: phase_state.get('id')}

  get_assignment: -> @thinkspace.get_current_assignment()
  get_phase:      -> @thinkspace.get_current_phase()
  get_ownerable:  -> @totem_scope.get_ownerable_record()
