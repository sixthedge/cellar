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

  selected_value_obs: ember.observer 'selected_value', ->
    console.log('selected_value changed to ', @get('selected_value'))

  actions: 
    create: -> @get('manager').add_quant_item()

    select: (val) ->
      @set('selected_value', val)