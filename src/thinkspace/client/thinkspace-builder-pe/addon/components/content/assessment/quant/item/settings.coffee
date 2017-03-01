import ember          from 'ember'
import ns             from 'totem/ns'
import validations    from 'totem/mixins/validations'
import base           from 'thinkspace-base/components/base'

###
# # settings.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend validations,
  # ### Services
  #manager: ember.inject.service ns.to_p 'peer_assessment', 'builder', 'manager'

  # ### Computed properties
  points_min:      ember.computed.reads 'model.points_min'
  points_max:      ember.computed.reads 'model.points_max'
  label:           ember.computed.reads 'model.label'
  scale_label_min: ember.computed.reads 'model.settings.labels.scale.min'
  scale_label_max: ember.computed.reads 'model.settings.labels.scale.max'
  has_comments:    ember.computed.reads 'model.settings.comments.enabled'

  # ### Components
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'

  update_model: ->
    model           = @get 'model'
    points_min      = @get 'points_min'
    points_max      = @get 'points_max'
    label           = @get 'label'
    scale_label_min = @get 'scale_label_min'
    scale_label_max = @get 'scale_label_max'
    has_comments    = @get 'has_comments'

    model.set_value 'points_min',      points_min
    model.set_value 'points_max',      points_max
    model.set_value 'label',           label
    model.set_value 'scale_label_min', scale_label_min
    model.set_value 'scale_label_max', scale_label_max
    model.set_value 'has_comments',    has_comments

    console.info "[pa:builder:quant:settings] Model post update is: ", model

  actions:
    toggle_has_comments: -> @toggleProperty 'has_comments'
    back:                -> @sendAction 'back'
    save:                -> 
      @update_model()
      #@get('manager').save_model()
      @sendAction 'back'

  validations:
    points_min:
      numericality: true
      property_less_than:
        smaller_property: 'points_min'
        larger_property:  'points_max'
        message:          'Minimum points must be less than maximum points.'
    points_max:
      numericality: true