import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # settings.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  # ### Services
  #manager: ember.inject.service ns.to_p 'peer_assessment', 'builder', 'manager'

  # ### Properties
  feedback_types: [{id: 'positive', label: 'Positive'}, {id: 'constructive', label: 'Constructive'}]
  types:          [{id: 'textarea', label: 'Large Text'}, {id: 'text', label: 'Small Text'}]

  # ### Computed properties
  label:               ember.computed.reads 'model.label'

  type:       ember.computed.reads 'model.type'
  type_label: ember.computed 'type', ->
    types = @get 'types'
    type  = @get 'type'
    type  = types.findBy 'id', type
    type.label

  feedback_type:       ember.computed.reads 'model.feedback_type'
  feedback_type_label: ember.computed 'feedback_type', ->
    types = @get 'feedback_types'
    type  = @get 'feedback_type'
    type  = types.findBy 'id', type
    type.label

  # ### Components
  c_checkbox: ns.to_p 'common', 'shared', 'checkbox'
  c_dropdown: ns.to_p 'common', 'dropdown'

  update_model: ->
    model         = @get 'model'
    label         = @get 'label'
    type          = @get 'type'
    feedback_type = @get 'feedback_type'

    model.set_value 'label',         label
    model.set_value 'type',          type
    model.set_value 'feedback_type', feedback_type

    console.info "[pa:builder:qual:settings] Model post update is: ", model

  actions:
    back:                -> @sendAction 'back'
    save:                -> 
      @update_model()
      #@get('manager').save_model()
      @sendAction 'back'

    select_feedback_type: (type) ->  @set 'feedback_type', type.id
    select_type:          (type) -> @set 'type', type.id