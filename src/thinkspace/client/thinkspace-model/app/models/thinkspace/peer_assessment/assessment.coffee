import ember from 'ember'
import ta    from 'totem/ds/associations'
import util  from 'totem/util'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.belongs_to 'assessment_template', reads: {}
  ),

  authable_type:          ta.attr('string')
  authable_id:            ta.attr('number')
  state:                  ta.attr('string')
  assessment_template_id: ta.attr('number')
  modified_template:      ta.attr('boolean')
  value:                  ta.attr()

  # ### Computed properties
  is_categories:           ember.computed.equal 'assessment_type', 'categories'
  is_balance:              ember.computed.equal 'assessment_type', 'balance'
  is_custom:               ember.computed.equal 'assessment_type', 'custom'
  has_no_assessment_template: ember.computed.empty 'assessment_template_id'
  # is_active:             ember.computed.equal 'state', 'active'
  # is_approved:           ember.computed.equal 'state', 'approved'
  # is_read_only:          ember.computed.or 'is_active', 'is_approved'
  # is_not_active:         ember.computed.not 'is_active'

  # Abstractions from JSON keys to reference in templates.
  qualitative_items:          ember.computed 'value.qualitative.@each', -> @get('value.qualitative')
  quantitative_items:         ember.computed 'value.quantitative.@each', -> @get('value.quantitative')
  assessment_type:            ember.computed 'value.options.type', -> @get('value.options.type')
  points:                     ember.computed 'value.options.points', -> @get('value.options.points')
  points_per_member:          ember.computed 'value.options.points.per_member', -> @get('points.per_member')
  points_min:                 ember.computed 'value.options.points.min', -> @get('points.min')
  points_max:                 ember.computed 'value.options.points.max', -> @get('points.max')
  points_different:           ember.computed 'value.options.points.different', -> @get('points.different')
  points_descriptive_enabled: ember.computed 'value.options.points.descriptive.enabled', -> @get('points.descriptive.enabled')
  points_descriptive_low:     ember.computed 'value.options.points.descriptive.values', -> 
    values = @get('points.descriptive.values')
    values.get('firstObject') if ember.isArray(values)
  points_descriptive_medium:    ember.computed 'value.options.points.descriptive.values', ->
    values = @get('points.descriptive.values')
    values[1] if ember.isArray(values) # Middle value.
  points_descriptive_high:    ember.computed 'value.options.points.descriptive.values', ->
    values = @get('points.descriptive.values')
    values.get('lastObject') if ember.isArray(values)

  positive_qualitative_items:     ember.computed 'value.qualitative.@each', -> @get_qualitative_items_for_type('positive')
  constructive_qualitative_items: ember.computed 'value.qualitative.@each', -> @get_qualitative_items_for_type('constructive')

  quant_items: ember.computed 'value.quantitative.@each', -> @get 'value.quantitative'
  qual_items:  ember.computed 'value.qualitative.@each', -> @get 'value.qualitative'

  # ### Events
  didLoad: -> @validate_value()

  # ### Helpers
  get_qualitative_items_for_type: (type) ->
    items            = @get 'qualitative_items'
    items_of_type    = []
    for item in items
      items_of_type.pushObject item if ember.isEqual(item.feedback_type, type)
    items_of_type

  get_qualitative_label_for_id: (id) ->
    items = @get('qualitative_items')
    return unless ember.isPresent(id) and ember.isPresent(items.findBy('id', id))
    item = items.findBy('id', id)
    item.label

  validate_value: ->
    value                            = @get 'value'
    return unless ember.isPresent(value)
    value.qualitative                = [] unless ember.isArray(value.qualitative)
    value.quantitative               = [] unless ember.isArray(value.quantitative)
    value.options                    = {} unless ember.isPresent(value.options)
    value.options.points             = {} unless ember.isPresent(value.options.points)
    value.options.points.descriptive = {} unless ember.isPresent(value.options.points.descriptive)

  value_did_change: -> @propertyDidChange 'value'


  set_points_per_member: (value) -> util.set_path_value(@, 'value.options.points.per_member', value)
  reset_points_per_member:       -> util.set_path_value(@, 'value.options.points.per_member', null)
  set_points_min:        (value) -> util.set_path_value(@, 'value.options.points.min', value)
  set_points_max:        (value) -> util.set_path_value(@, 'value.options.points.max', value)
  set_points_different:  (value) -> util.set_path_value(@, 'value.options.points.different', value)
  set_type:              (type)  -> util.set_path_value(@, 'value.options.type', type)
  set_is_balance:        ->         @set_type 'balance'
  reset_is_balance:      ->         @reset_type()
  reset_type:            ->         @set_type null
  set_is_categories:     ->         @set_type 'categories'

  # ### Builder
  builder_abilities: ->
    new ember.RSVP.Promise (resolve, reject) =>
      can_edit  = !@get('is_read_only')
      abilities = 
        has_builder_content:  can_edit
        has_builder_settings: can_edit
      resolve(abilities)

  # builder_messages: ->
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     messages     = []
  #     is_active    = @get 'is_active'
  #     is_approved  = @get 'is_approved'
  #     # TODO i18n
  #     if is_active
  #       messages.pushObject 'The evaluation has been activated, so it cannot be edited.'
  #       messages.pushObject 'The evaluation has been activated, so you cannot modify the teams associated with it.'
  #     if is_approved
  #       messages.pushObject 'The evaluation has been sent, it has been set to read-only.'
  #     resolve(messages)
  #   , (error) => @error(error)