import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import qual_item from './item'

###
# # preview.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  # ### Services
  #manager: ember.inject.service ns.to_p 'peer_assessment', 'builder', 'manager'

  # ### Properties
  classNameBindings: ['is_selected:is-selected']
  classNames:        ['ts-pa_qual-item', 'ts-pa_item']

  edit_mode:            null # content, settings, preview
  is_managing_settings: false
  placeholder_text:     'Qualitative response here...'

  # ### Computed properties
  is_edit_mode_content: ember.computed.equal 'edit_mode', 'content'

  is_textarea: ember.computed.reads 'model.is_textarea'
  is_text:     ember.computed.reads 'model.is_text'

  # ### Components
  c_qual_settings: ns.to_p 'peer_assessment', 'builder', 'assessment', 'qual', 'settings'

  # ### Events
  init: ->
    @_super()
    model      = @get 'model'
    assessment = @get 'assessment'
    item       = qual_item.create
      model:      model
      assessment: assessment
    @set 'model', item
    console.log "PREVIEW", @

  mouseEnter: (event) -> @focusIn(event)
  mouseLeave: (event) -> @focusOut(event)
  focusIn:    (event) -> @set_is_selected()
  focusOut:   (event) -> @reset_is_selected()

  # ### Helpers
  set_is_selected:   -> @set 'is_selected', true
  reset_is_selected: -> @set 'is_selected', false

  actions:
    set_is_managing_settings:   -> @set 'is_managing_settings', true
    reset_is_managing_settings: -> @set 'is_managing_settings', false

    order_up:   ->
      # model = @get 'model.model'
      # @get('manager').reorder_qual_item(model, -1) # Model property is the actual object.

    order_down: ->
      # model = @get 'model.model'
      # @get('manager').reorder_qual_item(model, 1) # Model property is the actual object.

    duplicate:  -> 
      # model = @get 'model.model'
      # @get('manager').duplicate_qual_item(model)

    delete: ->
      # model = @get 'model.model'
      # @get('manager').delete_qual_item(model)