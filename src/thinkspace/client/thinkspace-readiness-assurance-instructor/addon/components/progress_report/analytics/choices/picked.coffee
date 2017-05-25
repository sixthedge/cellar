import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  # # Properties
  model: null # Choice

  # # Computed properties
  is_correct: ember.computed.reads 'model.correct'