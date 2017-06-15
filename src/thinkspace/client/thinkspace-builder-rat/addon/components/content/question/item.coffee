import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  is_editing: false
  index:      null
  is_new:     ember.computed.reads 'model.is_new'

  init_base: -> @set('is_editing', @get('is_new'))

  update_model: ->
    @get('model').persist().then (valid) =>
      if valid
        @set_loading('update')
        @send('toggle_is_editing', false)
        @get('manager').update_question(@get('type'), @get('model'))
        @get('manager').save_assessment(@get('type')).then =>
          @get('model').set('is_new', false)
          @get('step').create_question_items(ember.makeArray(@get('model')))
          @reset_loading('update')

  actions:
    toggle_is_editing: (val) -> 
      @set('is_editing', val)

    update_question: ->
      @update_model()

    delete: (type, item_obj) ->
      @set_loading('update')
      @get('step').delete_question_item(type, item_obj).then =>
        @reset_loading('update')