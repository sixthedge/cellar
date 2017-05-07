import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  # # Properties
  classNames:  ['radio__item']
  model:       null
  name:        null
  group_value: null # The value for the group, if present.

  # # Computed properties
  id:      ember.computed 'model', -> "#{@get_element_id()}-radio"
  checked: ember.computed -> @get('group_value') == @get('value')

  value:   ember.computed.reads 'model.value'
  label:   ember.computed.reads 'model.label'
  summary: ember.computed.reads 'model.summary'

  # # Helpers
  get_element_id: -> @get('elementId')
  get_value:      -> @get('value')

  # # Events
  click: -> @sendAction('changed', @get_value())
