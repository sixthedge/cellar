import ember     from 'ember'
import base      from 'thinkspace-base/components/base'

###
# # item.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()
  builder: ember.inject.service()

  step: ember.computed.reads 'builder.step_content'

  ## The raw json needed by the manager
  item: ember.computed.reads 'model.model'
  
  type:       'qual'
  model:      null
  is_editing: false

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
    
    ## Bool passed by qual/item/edit component to indicate whether the changeset is 
    update: ->
      @set_loading('all')
      @get('model').changeset_persist().then =>
        @get('manager').update_qual_item(@get('model'))
        @get('manager').save_model().then =>
          @get('manager').create_question_items(@get('type'), {delta: ember.makeArray(@get('model'))})
          @set('is_editing', false)
          @reset_loading('all')

    duplicate: ->
      item = @get('item')
      @get('step').duplicate_item(@get('type'), item.id, item)

    delete: ->
      item = @get('item')
      @set_loading('all')
      @get('manager').delete_item(@get('type'), item).then =>
        @reset_loading('all')

    reorder: (offset) ->
      item = @get('item')
      step = @get('step')
      step.reorder_item(@get('type'), item, offset)