import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # preview.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
import quant_item from './item'

export default base.extend
  # ### Services
  #manager: ember.inject.service ns.to_p 'peer_assessment', 'builder', 'manager'

  # ### Properties
  classNameBindings: ['is_selected:is-selected']
  classNames:        ['ts-pa_quant-item', 'ts-pa_item']

  # Slider properties
  fill_class:        'ts-rangeslider_fill'
  handle_class:      'ts-rangeslider_handle'
  range_class:       'ts-rangeslider'
  fill_class_hex:    
    'green':  '#6dc05e'
    'yellow': '#fcb725'
    'red':    '#fb6b6b'
  slider_background_template: "<div class='ts-rangeslider_background' />"

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
    set_is_managing_settings:   -> @set 'is_managing_settings', true
    reset_is_managing_settings: -> 
      @set 'is_managing_settings', false
      ember.run.schedule 'afterRender', @, => @didInsertElement() # Re-initialize the slider.

    order_up:   ->
      model = @get 'model.model'
      #@get('manager').reorder_quant_item(model, -1) # Model property is the actual object.

    order_down: ->
      model = @get 'model.model'
      #@get('manager').reorder_quant_item(model, 1) # Model property is the actual object.

    duplicate:  -> 
      model = @get 'model.model'
      #@get('manager').duplicate_quant_item(model)

    delete: ->
      model = @get 'model.model'
      #@get('manager').delete_quant_item(model)