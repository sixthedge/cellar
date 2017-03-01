import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import qual_item   from 'thinkspace-builder-pe/items/qual'
import quant_item  from 'thinkspace-builder-pe/items/quant'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  classNameBindings: ['readonly:is-readonly']

  value:    null
  template: null

  quant_items:    ember.computed 'value.quantitative.@each', -> 
    ## Create objects here instead of downstream
    items = @get 'value.quantitative'
    if ember.isPresent(items)
      @create_quant_item(item) for item in items

  qual_items:     ember.computed 'value.qualitative.@each', -> 
    ## Create objects here instead of downstream
    items = @get 'value.qualitative'
    if ember.isPresent(items)
      @create_qual_item(item) for item in items

  create_qual_item: (item) ->
    qual_item.create
      model:      item
      assessment: @get('model')

  create_quant_item: (item) ->
    quant_item.create
      model:      item
      assessment: @get('model')

  actions:
    change_template: -> @get('step').set_is_editing_template()
