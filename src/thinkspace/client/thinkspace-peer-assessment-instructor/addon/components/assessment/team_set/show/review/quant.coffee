import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Properties
  tagName:    ''
  model:      null # JSON item from assessment
  review:     null
  assessment: null
  item:       null # JSON item from review

  is_editing:  false

  # ### Computed properties
  label:       ember.computed.reads 'model.label'
  has_value:   ember.computed.notEmpty 'value'
  is_not_sent: ember.computed.reads 'review.is_not_sent'

  # ### Initialization
  init_base: ->
    review = @get 'review'
    model  = @get 'model'
    value  = review.get_quantitative_value_for_id model.id
    @set 'value', value