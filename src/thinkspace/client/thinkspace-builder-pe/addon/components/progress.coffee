import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # progress.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  builder: ember.inject.service()

  steps: ember.computed.reads 'builder.steps'
  model: ember.computed.reads 'builder.model'