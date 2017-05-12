import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend
  # # Properties
  phase_manager: ember.inject.service()

  titleToken: (model) -> model.get('title')

  afterModel: (assignment, transition) ->
    transition.abort()  unless assignment
    @current_models().set_current_models(assignment: assignment).then =>
      pm = @get('phase_manager')
      pm.set_all_phase_states()