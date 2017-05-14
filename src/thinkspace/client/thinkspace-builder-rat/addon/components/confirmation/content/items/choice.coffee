import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  assessment: null
  model:      null

  label:   ember.computed.reads 'model.label'
  prefix:  ember.computed.reads 'model.prefix'

  display: ember.computed 'label', 'prefix', -> return "#{@get('prefix')}. #{@get('label')}"

  init_base: ->
    @get('model').validate()
