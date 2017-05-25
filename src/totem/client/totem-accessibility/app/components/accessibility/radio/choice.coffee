import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  # # Properties
  classNames:        ['radio__item']
  classNameBindings: ['model.classes']
  model:             null
  name:              null
  group_value:       null # The value for the group, if present.

  # # Computed properties
  id:      ember.computed 'model', -> "#{@get_element_id()}-radio"
  checked: ember.computed 'model', 'model.checked', ->
    return @get('model.checked') if ember.isPresent(@get('model.checked'))
    @get('group_value') == @get('value')

  value:    ember.computed.reads 'model.value'
  label:    ember.computed.reads 'model.label'
  summary:  ember.computed.reads 'model.summary'
  delay:    ember.computed.reads 'model.delay'
  disabled: ember.computed 'model', 'checked', 'model.disabled', ->
    return false if @get('checked')
    @get('model.disabled')

  # # Helpers
  get_element_id: -> @get('elementId')
  get_value:      -> @get('value')

  send_changed: ->
    return if @get('disabled')
    @sendAction('changed', @get_value())

  send_delayed: ->
    return unless @get('delay')
    return if     @get('disabled')
    @sendAction('delayed', @get_value())

  # # Events
  keyPress: (event) ->
    # Handle Enter/Space presses.
    return true unless @get('delay')
    if event.keyCode == 0 || event.keyCode == 32 || event.keyCode == 13
      @send_delayed()
      @send_changed()

  click: (event) ->
    if event.target.nodeName == 'INPUT'
      if @get('delay')
        # Do not fire `click` on arrow key presses, delay it until a keypress.
        if event.clientX != 0 and event.clientY != 0
          @send_delayed()
      else
        @send_changed()

