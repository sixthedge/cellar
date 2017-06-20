import ember      from 'ember'
import base       from 'thinkspace-base/components/base'

###
# # item.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()
  builder: ember.inject.service()

  step: ember.computed.reads 'builder.step_content'
  type: 'quant'

  ## The raw json needed by the manager
  item: ember.computed.reads 'model.model'

  edit_mode:  null # content, settings, preview
  is_editing: false

  is_edit_mode_content: ember.computed.equal 'edit_mode', 'content'

  actions:
    edit: (bool) -> 
      model = @get('model')
      if bool
        @set('is_editing', bool)
      else
        @set_loading('all')
        @get('model').changeset_rollback().then =>
          @set('is_editing', bool)
          @reset_loading('all')
    
    duplicate: ->
      item = @get('item')
      @get('step').duplicate_item(@get('type'), item.id, item)

    delete: ->
      item = @get('item')
      @get('manager').delete_item(@get('type'), item)

    update: ->
      @set_loading('all')
      @get('model').changeset_persist().then =>
        @get('manager').update_quant_item(@get('model'))
        @get('manager').save_model().then =>
          @get('manager').create_question_items(@get('type'), {delta: ember.makeArray(@get('model'))})
          @set('is_editing', false)
          @reset_loading('all')

    reorder: (offset) ->
      item = @get('item')
      step = @get('step')
      step.reorder_item(@get('type'), item, offset)
