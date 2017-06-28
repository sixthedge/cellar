import ember     from 'ember'
import base      from 'thinkspace-base/components/base'

###
# # section.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager:        ember.inject.service()
  builder:        ember.inject.service()

  step:           ember.computed.reads 'builder.step_content'

  selected_value: null
  is_balance:     null
  is_not_balance: ember.computed.not 'is_balance'

  actions: 
    create: -> 
      @get('step').add_item_with_type('quant')

    select: (val) ->
      @set('selected_value', val)