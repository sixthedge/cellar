import ember from 'ember'
import base  from 'thinkspace-base/components/base'

## ### Configuration:
#
# modal content:
#   modal_partial: string of partial to render in place of the modal content
#   title                            string of text for the h4 element
#   subtitle                         string of text for the h5 element
#   description                      string of text for the p element
#   confirm_text:                    string of text for the confirm button
#   deny_text:                       string of text for the deny button
#   modal_class_names:               string of class names for the modal, separated by spaces
# modal reveal:                      
#   modal_reveal_anchor_class_names: string of class names for the anchor for the modal reveal, separated by spaces
#   modal_reveal_icon_class_names:   string of class names for the icon for the modal reveal, separated by spaces
#   modal_reveal_partial:            string of partial to render in place of the modal reveal icon
## ###


export default base.extend
  modal_id: ember.computed 'elementId', -> "modal-#{@get('elementId')}"

  title:        'Are you sure?'
  confirm_text: 'Yes'
  deny_text:    'Cancel'
  show_close:   true

  modal_class_names:         ''
  default_modal_class_names: 'modal reveal'
  all_modal_class_names:     ember.computed 'modal_class_names', -> 
    class_names = @get('default_modal_class_names')
    unless ember.isEmpty @get('modal_class_names')
      class_names = class_names + ' ' + @get('modal_class_names')
    class_names

  get_$modal: -> $("##{@get('modal_id')}")

  set_modal: (modal) -> @set 'modal', modal
  get_modal: -> @get 'modal'

  init_base: -> 
    ember.run.schedule 'afterRender', =>
      @set_modal new Foundation.Reveal(@get_$modal())

  willDestroyElement: -> 
    $modal = @get_$modal()
    $modal.foundation('destroy')
    $modal.remove() # TODO: Not sure why 'destroy' doesn't remove it.

  actions:

    close: ->
      @get_modal().close()