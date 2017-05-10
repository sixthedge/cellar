import ember      from 'ember'
import base       from 'thinkspace-base/components/base'
import choice_obj from 'thinkspace-builder-rat/items/question/choice'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  assessment: null
  model:      null

  answer:   ember.computed.reads 'model.answer'
  question: ember.computed.reads 'model.question'
  choices:  ember.computed.reads 'model.choices'

  display_question: ember.computed 'question', -> return "#{@get('index') + 1}. #{@get('question')}"

  choice_items: ember.computed 'choices', ->
    choice_items = ember.makeArray()
    items      = @get('choices')
    if ember.isPresent(items)
      items.forEach (item, index) =>
        item = @create_choice_item(item, index)
        choice_items.pushObject(item)
    choice_items

  create_choice_item: (item, index) -> choice_obj.create(model: item, index: index, answer: @get('answer'))

  init_base: ->
    @get('model').validate()

