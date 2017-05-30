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

    duplicate:      -> @get('step').duplicate_question_item(@get('type'), @get('model.model'))
    delete:         -> 
      @sendAction('delete', @get('type'), @get('model.model'))
    reorder_up:     -> @get('step').reorder_up(@get('type'), @get('model.model'))
    reorder_down:   -> @get('step').reorder_down(@get('type'), @get('model.model'))
    reorder_top:    -> @get('step').reorder_top(@get('type'), @get('model.model'))
    reorder_bottom: -> @get('step').reorder_bottom(@get('type'), @get('model.model'))
