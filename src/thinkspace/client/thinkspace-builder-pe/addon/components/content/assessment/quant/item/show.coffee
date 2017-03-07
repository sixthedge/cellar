import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # show.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  # ### Properties
  classNameBindings: ['is_selected:is-selected']
  classNames:        ['ts-pa_quant-item', 'ts-pa_item', 'pe-builder_border']

  # Slider properties
  fill_class:        'ts-rangeslider_fill'
  handle_class:      'ts-rangeslider_handle'
  range_class:       'ts-rangeslider'
  fill_class_hex:    
    'green':  '#6dc05e'
    'yellow': '#fcb725'
    'red':    '#fb6b6b'
  slider_background_template: "<div class='ts-rangeslider_background' />"

  is_balance:     null
  is_not_balance: ember.computed.not 'is_balance'

  # ### Observers
  fill_color_change: ember.observer 'fill_color', ->
    fill_color     = @get 'fill_color'
    fill_class     = @get 'fill_class'
    fill_class_hex = @get 'fill_class_hex'
    color          = fill_class_hex[fill_color]
    @$(".#{fill_class}").css('background-color', color)

  didInsertElement: ->
    @$('input[type="range"]').rangeslider
        polyfill:    false
        rangeClass:  @get 'range_class'
        fillClass:   @get 'fill_class'
        handleClass: @get 'handle_class'
        onInit: => @slider_set_ruler()
        onSlide: (position, value) => @slider_set_color(value)

  willDestroyElement: ->
    @$('input[type="range"]').rangeslider('destroy')

  mouseEnter: (event) -> @focusIn(event)
  mouseLeave: (event) -> @focusOut(event)
  focusIn:    (event) -> @set_is_selected()
  focusOut:   (event) -> @reset_is_selected()

  # ### Helpers
  set_is_selected:   -> @set 'is_selected', true
  reset_is_selected: -> @set 'is_selected', false

  # ### Slider helpers
  slider_set_ruler: ->
    range_class = @get 'range_class'
    template    = @get 'slider_background_template'
    $background = $(template)
    @$(".#{range_class}").prepend($background)

  slider_set_color: (value) ->
    points_max = 5#@get 'points_max'
    percentage = value / points_max
    switch 
      when percentage >= 0.67
        @set 'fill_color', 'green'
      when percentage >= 0.33 and percentage < 0.67
        @set 'fill_color', 'yellow'
      when percentage >= 0 and percentage < 0.33
        @set 'fill_color', 'red'

  actions: 
    edit: -> @sendAction('edit', true)

    duplicate:      -> @sendAction('duplicate')
    delete:         -> @sendAction('delete')
    
    reorder_up:     -> @sendAction('reorder', -1)
    reorder_down:   -> @sendAction('reorder', 1)
    reorder_top:    -> @sendAction('reorder', 'top')
    reorder_bottom: -> @sendAction('reorder', 'bottom')