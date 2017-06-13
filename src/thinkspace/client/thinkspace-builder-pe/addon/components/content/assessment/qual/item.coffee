import ember     from 'ember'
import base      from 'thinkspace-base/components/base'

###
# # item.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  ## The raw json needed by the manager
  item: ember.computed.reads 'model.model'
  
  model:      null
  edit_mode:  null # content, settings, preview
  is_editing: false

  is_edit_mode_content: ember.computed.equal 'edit_mode', 'content'

  actions:
    edit: (bool) -> @set('is_editing', bool)
    
    ## Bool passed by qual/item/edit component to indicate whether the changeset is 
    update: ->
      @get('manager').save_model().then =>
        @send('edit', false)
        @get('step').update_model()
      
    duplicate: ->
      item = @get('item')
      @get('manager').duplicate_item('qual', item.id, item)

    delete: ->
      item = @get('item')
      @get('manager').delete_item('qual', item)

    reorder: (offset) ->
      item = @get('item')
      @get('manager').reorder_qual_item(item, offset)