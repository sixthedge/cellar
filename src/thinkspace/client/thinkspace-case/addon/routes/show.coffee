import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  titleToken: (model) -> model.get('title')

  phase_manager: ember.inject.service()

  model: (params) -> @tc.find_record_with_message ns.to_p('assignment'), params.assignment_id

  afterModel: (assignment, transition) ->
    transition.abort()  unless assignment
    @current_models().set_current_models(assignment: assignment).then =>
      pm = @get('phase_manager')
      pm.set_all_phase_states()

      assignment.get('assignment_type').then (assignment_type) =>
        return unless ember.isPresent(assignment_type)
        if assignment_type.get('is_pe')
          @transitionToExternal('thinkspace-peer-assessment.overview', assignment)
