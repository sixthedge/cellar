import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  # ### Properties
  model:           null # Assessment record

  # ### Computed properties
  assessment: ember.computed.reads 'model'
  