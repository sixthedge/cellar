import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  manager: null # peer_assessment/evaluation
  model:   null # item
  comment: null

  # #### Slider properties
  slider:
    classes:
      fill:   'ts-rangeslider_fill'
      handle: 'ts-rangeslider_handle'
      range:  'ts-rangeslider'
    colors:
      fill:
        'green':  '#6dc05e'
        'yellow': '#fcb725'
        'red':    '#fb6b6b'
    templates:
      ruler: "<div class='ts-rangeslider_ruler' />"
      ticks: "<div class='ts-rangeslider_ticks' />"
      background: "<div class='ts-rangeslider_background' />"
    step: 1

  # ### Computed properties
  review:           ember.computed.reads 'manager.review'
  assessment:       ember.computed.reads 'manager.model'
  points_different: ember.computed.reads 'assessment.points_different'
  is_read_only:     ember.computed.or 'manager.is_read_only', 'manager.is_review_read_only'

  # #### Model computed properties
  # => These come from the `model` which is a portion of the assessment's value JSON.
  points_min: ember.computed 'assessment.points_min', 'model', ->
    value = @get_model_property('settings.points.min')
    return value if ember.isPresent(value)  # To catch the value of 0
    value or @get('assessment.points_min')

  points_max: ember.computed 'assessment.points_max', 'model', ->
    value = @get_model_property('settings.points.max')
    return value if ember.isPresent(value)
    value or @get('assessment.points_max')

  points_descriptive_enabled: ember.computed 'assessment.points_descriptive_enabled', 'model', ->
    (@get('points_descriptive_low') and @get('points_descriptive_high')) or @get('assessment.points_descriptive_enabled')

  points_descriptive_low: ember.computed 'assessment.points_descriptive_low', 'model', ->
    @get_model_property('settings.labels.scale.min') or @get('assessment.points_descriptive_low')

  points_descriptive_high: ember.computed 'assessment.points_descriptive_high', 'model', ->
    @get_model_property('settings.labels.scale.max') or @get('assessment.points_descriptive_high')

  can_comment:      ember.computed 'model', -> @get_model_property('settings.comments.enabled')

  # Observers
  review_change: ember.observer 'review', -> @initialize_review()

  fill_color_change: ember.observer 'fill_color', ->
    fill_color     = @get 'fill_color'
    fill_class     = @get_slider_class 'fill'
    fill_class_hex = @get 'fill_class_hex'
    color          = @get_slider_color fill_color
    @$(".#{fill_class}").css('background-color', color)

  # Events
  init: ->
    @_super()
    model_id      = @get('model.id')
    assessment_id = @get('assessment.id')
    ember.defineProperty @, 'slider_value', ember.computed 'review', "review.value.quantitative.#{model_id}.value", ->
      review = @get('review')
      return unless ember.isPresent(review)
      value = review.get_quantitative_value_for_id(model_id)
      if ember.isPresent(value) then return value else return 0  

  didInsertElement: ->
    @$('input[type="range"]').rangeslider
        polyfill:    false
        rangeClass:  @get_slider_class('range')
        fillClass:   @get_slider_class('fill')
        handleClass: @get_slider_class('handle')
        onInit: => @slider_set_ruler()
        onSlide: (position, value) => @slider_set_color(value); @slider_set_value(value)
        onSlideEnd: => @manager_save_review()
    if @get('points_descriptive_enabled')
      range_class = ".#{@get_slider_class('range')}"
      @$(range_class).addClass('is-descriptive') 
    @initialize_review()

  willDestroyElement: ->
    @$('input[type="range"]').rangeslider('destroy')

  # Helpers
  initialize_review: ->
    value    = @get('slider_value')
    model_id = @get('model.id')
    comment  = @get('review').get_quantitative_comment_for_id(model_id)
    $slider  = @$('input[type="range"]')
    $slider.val(value).change()
    @set('comment', comment)
    ember.run.schedule 'afterRender', =>
      $slider.rangeslider('update') # Disable any sliders that should be disabled.

  get_model_property: (path) ->
    model = @get 'model'
    model = ember.Object.create(model)
    model.get(path)

  manager_save_review: ->  @get('manager').save_review()

  get_slider: (prop) ->
    slider = @get 'slider'
    slider[prop]

  get_slider_class: (prop) ->
    classes = @get_slider 'classes'
    classes[prop]

  get_slider_template: (prop) ->
    templates = @get_slider 'templates'
    templates[prop]

  get_slider_color: (prop) ->
    colors = @get_slider 'colors'
    colors.fill[prop]

  slider_set_ruler: ->
    range_class = @get_slider_class 'range'
    points_min  = @get 'points_min'
    points_max  = @get 'points_max'
    ruler       = ''
    ticks       = ''
    i           = points_min
    while i    <= points_max
      ruler += i + ' '
      ticks += '| '
      i      = i + @get_slider 'step'

    template    = @get_slider_template 'ruler'
    $ruler      = $(template)
    template    = @get_slider_template 'ticks'
    $ticks      = $(template)
    template    = @get_slider_template 'background'
    $background = $(template)
    $ruler.html(ruler)
    $ticks.html(ticks)
    # TODO: Come up with a more scalable way of handling the ruler, first, middle, last probably.
    # @$(".#{range_class}").prepend($ruler) unless @get('points_descriptive_enabled')
    @$(".#{range_class}").prepend($background)
    @$(".#{range_class}").prepend($ticks)
    
  slider_set_value: (value) -> @get('manager').set_quantitative_value(@get('model.id'), value)

  slider_set_color: (value) ->
    points_max = @get 'points_max'
    percentage = value / points_max
    switch 
      when percentage >= 0.67
        @set 'fill_color', 'green'
      when percentage >= 0.33 and percentage < 0.67
        @set 'fill_color', 'yellow'
      when percentage >= 0 and percentage < 0.33
        @set 'fill_color', 'red'

  actions:
    save_comment: -> 
      manager = @get 'manager'
      manager.set_quantitative_comment @get('model.id'), @get('comment')