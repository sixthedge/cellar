import ember from 'ember'

export default ember.Component.extend
  # # Properties
  options: null
  value:   null # Property from the parent that is being set.

  # # Computed properties
  # ## Group label
  # Handles the root level label that wraps all of the choices.
  label:     ember.computed.reads 'options.group.label'
  has_label: ember.computed.notEmpty 'label'
  label_id:  ember.computed 'options', -> "#{@get_element_id()}-group__label"

  # ## Choices
  choices: ember.computed.reads 'options.choices'
  name:    ember.computed 'options', -> "#{@get_element_id()}-group__name"

  # # Helpers
  get_element_id: -> @get('elementId')

  actions:
    changed: (value) -> @sendAction('changed', value)
