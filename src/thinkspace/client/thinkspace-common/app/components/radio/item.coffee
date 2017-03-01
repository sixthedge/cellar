import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  display_property: ember.computed.reads 'model.display_property'

  is_selected: ember.computed 'selected_item', 'model', -> 
    @get('selected_item') == @get('model.model')

  display: ember.computed 'model', 'display_property', ->
    model    = @get('model.model')
    property = @get('display_property')
    return model.get(property) if ember.isPresent(property)
    return model

  click: -> @sendAction 'select', @get('model')