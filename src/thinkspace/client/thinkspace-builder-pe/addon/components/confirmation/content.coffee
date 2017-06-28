import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()
  manager: ember.inject.service()

  model:      ember.computed.reads 'builder.model'
  step:       ember.computed.reads 'builder.step_content'
  assessment: ember.computed.reads 'manager.model'

  quant_items: ember.computed 'assessment.value.quantitative.@each', ->
    items = @get('assessment.value.quantitative')
    items


  qual_items: ember.computed 'assessment.value.qualitative.@each', ->
    items = @get('assessment.value.qualitative')
    items