import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # question/item/edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  ## Model is ember object wrapping raw question json

  manager: ember.inject.service()
  type:    null
  default_text: 'Choose an answer'

  choice_items: ember.computed.reads 'model.choice_items'
  answer:       ember.computed.reads 'model.changeset.answer'

  dropdown_text: ember.computed 'answer', ->
    if ember.isPresent(@get('answer')) then @get('model').get_choice_by_id(@get('answer')).get('prefix') else @get('default_text')

  select_answer: (choice) ->
    @get('model').select_answer(choice)

  update_model: -> 
    @get('model').save().then (success) =>
      @get('manager').save_model(@get('type')) if success

  actions:
    toggle_show: ->
      @get('model').changeset_rollback().then =>
        @sendAction('show', false)

    update: -> @update_model()

    add_choice: ->
      @get('model').add_choice_to_item(@get('type'), @get('model.id'))

    delete_choice: (choice) ->
      @get('model').delete_choice_from_item(@get('type'), @get('model.id'), choice)

    select_answer: (choice) -> @select_answer(choice)