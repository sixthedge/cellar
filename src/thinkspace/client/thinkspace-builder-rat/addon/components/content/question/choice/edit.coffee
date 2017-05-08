import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # choice/edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  ## Model is ember object wrapping raw choice json
  manager: ember.inject.service()
  model:   null

  prefix: ember.computed.reads 'model.prefix'

  actions:
    delete: ->
      @sendAction('delete', @get('model.model'))