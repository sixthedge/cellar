import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  is_editing: false

  actions:
    toggle_is_editing: (val) -> 
      @get('model').init() if val
      @set('is_editing', val)
