import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  gradebook: ember.inject.service()

  domain_phase_states: [
    {state: 'unlocked',  title: 'Unlocked',  description: 'The learner can access the phase and modify their responses.'},
    {state: 'locked',    title: 'Locked',    description: 'The learner cannot access this phase at all.'},
    {state: 'completed', title: 'Completed', description: 'The learner can view the phase, but not modify any responses.'}
  ]

  actions:
    save: (state) -> @sendAction 'save', @get('model'), state
