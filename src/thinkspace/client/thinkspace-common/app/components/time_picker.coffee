import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  ttz: ember.inject.service()

  # ### Properties
  attributeBindings: ['tabindex']
  tabindex:          1

  # ### Computed properties
  friendly_value: ember.computed 'value', ->
    value = @get 'value'
    return null unless ember.isPresent(value)
    @get('ttz').format value, format: 'h:mm a'

  # ### Observers
  value_observer: ember.observer 'value', -> @set_time()

  # ### Events
  focusIn: (e) ->
    picker = @get_time_picker()
    picker.open()
    e.stopPropagation()

  click: (e) ->
    picker = @get_time_picker()
    picker.open()
    e.stopPropagation()
    e.preventDefault()

  didInsertElement: ->
    $input          = @get_picker_input()
    options         = @get('time_options') or {}
    options.onClose = (=> @select_time())
    $input.pickatime(options)
    @set_time()

  # ### Time setters
  set_time: ->
    value = @get 'value'
    return unless ember.isPresent(value)
    value_type     = typeof value
    value          = new Date(value) if value_type == 'string' # handle ISOString()
    @get_time_picker().set 'select', value

  select_time: ->
    time = @get_time_picker_time()
    @sendAction 'select', time

  # ### Helpers
  get_picker_input:     -> @$('.ts-picker_input')
  get_time_picker:      -> @get_picker_input().pickatime('picker')
  get_time_picker_time: -> @get_time_picker().get('select')
