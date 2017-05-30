import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  is_editing: ember.computed 'model', ->
    model = @get('model.model')
    if ember.isPresent(model.new)
      true
    else
      false

  handle_new: ->
    model = @get('model.model')
    delete model.new if ember.isPresent(model.new)

  update_model: ->
    @get('model').persist().then (valid) =>
      if valid
        @set_loading('update')
        @send('toggle_is_editing', false)
        @get('manager').save_assessment(@get('type')).then =>
          @get('step').create_question_items(ember.makeArray(@get('model')))
          @reset_loading('update')

  actions:
    toggle_is_editing: (val) -> 
      @handle_new(val)
      @set('is_editing', val)

    update_question: ->
      @update_model()

    delete: (type, item_obj) ->
      @set_loading('update')
      @get('step').delete_question_item(type, item_obj).then =>
        @reset_loading('update')