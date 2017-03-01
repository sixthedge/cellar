import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  create_visible: false
  prompt:         'No tag'

  actions:
    close:  -> @sendAction 'close'
    create: -> @set 'create_visible', true
    cancel: -> @set 'create_visible', false
