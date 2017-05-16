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
    @get('ttz').format value, format: 'MMMM Do, YYYY'

  # ### Observers
  value_observer: ember.observer 'value', -> @set_date()

  # ### Events
  focusIn: (e) ->
    picker = @get_date_picker()
    picker.open()

  click: (e) ->
    picker = @get_date_picker()
    picker.open()

  didInsertElement: ->
    $input          = @$('.ts-picker_input')
    options         = @get('date_options') or {}
    options.onClose = (=> @select_date())
    $input.pickadate(options)
    @set_date_picker $input.pickadate('picker')
    @set_date()

  # ### Date setters
  set_date: ->
    value = @get 'value'
    return unless ember.isPresent(value)
    value_type     = typeof value
    value          = new Date(value) if value_type == 'string' # handle ISOString()
    @get_date_picker().set 'select', value

  select_date: ->
    date   = @get_date_picker_date()
    @sendAction 'select', date

  # ### Helpers
  set_date_picker:      (picker) -> @set 'picker', picker
  get_date_picker:      -> @get 'picker'
  get_date_picker_date: -> @get_date_picker().get('select')
