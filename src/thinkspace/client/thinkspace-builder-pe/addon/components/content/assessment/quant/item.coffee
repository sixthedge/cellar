import ember      from 'ember'
import base       from 'thinkspace-base/components/base'

###
# # item.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  ## The raw json needed by the manager
  item: ember.computed.reads 'model.model'

  edit_mode:  null # content, settings, preview
  is_editing: false

  is_edit_mode_content: ember.computed.equal 'edit_mode', 'content'

  actions:
    edit: (bool) -> @set('is_editing', bool)
    
    duplicate: ->
      item = @get('item')
      @get('manager').duplicate_item('quant', item.id, item)

    delete: ->
      item = @get('item')
      @get('manager').delete_item('quant', item)

    update: -> 
      @get('manager').save_model()
      @send('edit', false)

    reorder: (offset) ->
      item = @get('item')
      @get('manager').reorder_quant_item(item, offset)
