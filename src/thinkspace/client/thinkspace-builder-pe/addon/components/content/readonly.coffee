import ember       from 'ember'
import base        from 'thinkspace-base/components/base'
import qual_item   from 'thinkspace-builder-pe/items/qual'
import quant_item  from 'thinkspace-builder-pe/items/quant'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  classNameBindings: ['readonly:is-readonly']

  value:      null
  template:   null
  manager:    ember.inject.service()
  readonly:   ember.computed.reads 'step.is_readonly'
  assessment: ember.computed.reads 'manager.assessment'

  quant_items: null
  qual_items:  null

  value_obs: ember.observer 'value', ->
    @init_readonly_items()

  has_quant_items: ember.computed.notEmpty 'quant_items'
  has_qual_items:  ember.computed.notEmpty 'qual_items'

  init_base: ->
    @init_readonly_items()

  init_readonly_items: ->
    @create_readonly_items('quant')
    @create_readonly_items('qual')

  create_readonly_items: (type) ->
    value     = @get('value')
    return unless ember.isPresent(value)
    questions = value["#{type}itative"] || ember.makeArray()
    items     = ember.makeArray()

    questions.forEach (question) =>
      id = question.id
      i  = questions.indexOf(question)

      q_item = @create_readonly_item(type, question)  
      items.pushObject(q_item)

    @set("#{type}_items", items)

  create_readonly_item: (type, item) ->
    if type == 'qual'
      return @create_readonly_qual_item(item)
    else if type == 'quant'
      return @create_readonly_quant_item(item)

  create_readonly_qual_item: (item) ->
    qual_item.create
      model:      item
      assessment: @get('assessment')

  create_readonly_quant_item: (item) ->
    quant_item.create
      model:      item
      assessment: @get('assessment')


  actions:
    change_template: -> @get('step').set_is_editing_template()
