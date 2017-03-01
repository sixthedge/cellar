import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # qual.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  model: null
  index: null

  display_index: ember.computed 'index', -> @get('index') + 1

  label:         ember.computed.reads 'model.label'
  feedback_type: ember.computed.reads 'model.feedback_type'
  id:            ember.computed.reads 'model.id'

  display_feedback_type: ember.computed 'feedback_type', ->
    @get('feedback_type').capitalize() + ' feedback'