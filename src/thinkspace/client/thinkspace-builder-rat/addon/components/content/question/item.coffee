import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  is_editing: ember.computed 'model', ->
    model = @get('model.model')
    if ember.isPresent(model.new)
      true
    else
      false

  handle_new: ->
    model = @get('model.model')
    delete model.new if ember.isPresent(model.new)

  actions:
    toggle_is_editing: (val) -> 
      @get('model').init() if val
      @handle_new(val)
      @set('is_editing', val)
