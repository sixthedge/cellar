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

  select_answer: (choice) ->
    @get('model').select_answer(choice)

  actions:
    toggle_show: ->
      @get('model').changeset_rollback().then =>
        @sendAction('show', false)

    update: -> @sendAction('update')

    add_choice:             -> @get('model').add_choice_to_item(@get('type'), @get('model.id'))
    delete_choice: (choice) -> @get('model').delete_choice_from_item(@get('type'), @get('model.id'), choice)

    select_answer: (choice) -> @select_answer(choice)