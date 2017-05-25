import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # question/item/show.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  ## Model is ember object wrapping raw question json
  manager: ember.inject.service()
  type:    null

  choice_items: ember.computed.reads 'model.choice_items'

  actions:
    toggle_edit: ->
      @sendAction('edit', true)

    duplicate: -> @get('manager').duplicate_question_item(@get('type'), @get('model.model'))

    delete:    -> @get('manager').delete_question_item(@get('type'), @get('model.model'))

    reorder_up:     -> @get('manager').reorder_item(@get('type'), @get('model.model'), -1)
    reorder_down:   -> @get('manager').reorder_item(@get('type'), @get('model.model'), 1)
    reorder_top:    -> @get('manager').reorder_item(@get('type'), @get('model.model'), 'top')
    reorder_bottom: -> @get('manager').reorder_item(@get('type'), @get('model.model'), 'bottom')