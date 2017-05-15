import ember from 'ember'
import base  from 'thinkspace-common/components/modal/base'

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
# modal actions:                     
#   confirm:                         action to send confirmation to
#   deny:                            action to send denial to
## ###


export default base.extend
  layout: 'thinkspace-common/components/modal/base'
  show_close: false

  actions:
    confirm: ->
      @send 'close'
      @sendAction 'confirm'

    deny: ->
      @send 'close'
      @sendAction 'deny'