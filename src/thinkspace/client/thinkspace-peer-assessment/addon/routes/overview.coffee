import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  titleToken: (model) -> model.get('title')

  phase_manager: ember.inject.service()

  afterModel: (assignment, transition) ->
    transition.abort()  unless assignment
    @current_models().set_current_models(assignment: assignment).then =>
      pm = @get('phase_manager')
      pm.set_all_phase_states()