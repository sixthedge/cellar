import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # show.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  # ### Properties
  classNameBindings: ['is_selected:is-selected']
  classNames:        ['ts-pa_qual-item', 'ts-pa_item', 'pe-builder_border']

  placeholder_text:     'Qualitative response here...'

  is_textarea: ember.computed.reads 'model.is_textarea'
  is_text:     ember.computed.reads 'model.is_text'

  mouseEnter: (event) -> @focusIn(event)
  mouseLeave: (event) -> @focusOut(event)
  focusIn:    (event) -> @set_is_selected()
  focusOut:   (event) -> @reset_is_selected()

  # ### Helpers
  set_is_selected:   -> @set 'is_selected', true
  reset_is_selected: -> @set 'is_selected', false

  actions:
    edit: -> @sendAction('edit', true)

    duplicate: -> @sendAction('duplicate')
    delete: ->    @sendAction('delete')
    
    reorder_up:     -> @sendAction('reorder', -1)
    reorder_down:   -> @sendAction('reorder', 1)
    reorder_top:    -> @sendAction('reorder', 'top')
    reorder_bottom: -> @sendAction('reorder', 'bottom')
