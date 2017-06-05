import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # choice/show.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  
  ## Model is ember object wrapping raw choice json
  model: null

  prefix: ember.computed.reads 'model.prefix'
