import ember     from 'ember'
import base      from 'thinkspace-base/components/base'

###
# # section.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  tests: [1, 2, 3, 4, 5]

  selected_value: null
  is_balance:     null
  is_not_balance: ember.computed.not 'is_balance'

  actions: 
    create: -> @get('manager').add_quant_item()

    select: (val) ->
      @set('selected_value', val)