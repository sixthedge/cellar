import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # qual.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Properties
  # ### View Properties
  tagName:    ''

  # ### Internal Properties
  model:      null # JSON item from assessment
  review:     null
  assessment: null
  comment:    null # JSON item from review

  # ### Computed properties
  value:       ember.computed.reads 'comment.value'
  model_id:    ember.computed.reads 'model.id'
  label:       ember.computed.reads 'model.label'
  has_value:   ember.computed.notEmpty 'value'
  is_not_sent: ember.computed.reads 'review.is_not_sent'

  # ## Events
  init_base: ->
    review  = @get 'review'
    model   = @get 'model'
    comment = review.get_qualitative_comment_for_id model.id
    @set 'comment', comment
    @sendAction 'register', @

  willDestroyElement: -> @sendAction 'unregister', @