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

  update_model: -> 
    @get('model').save().then (success) =>
      @get('manager').save_model(@get('type')) if success

  actions:
    toggle_show: ->
      @get('model').changeset_rollback().then =>
        @sendAction('show')

    update: -> @update_model()

    add_choice: ->
      @get('manager').add_choice_to_item(@get('type'), @get('model.id'))

    delete_choice: (choice) ->
      @get('manager').delete_choice_from_item(@get('type'), @get('model.id'), choice)