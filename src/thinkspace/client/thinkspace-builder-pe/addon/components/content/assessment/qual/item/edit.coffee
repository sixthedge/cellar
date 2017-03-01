import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # preview.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  changeset: ember.computed.reads 'model.changeset'

  feedback_types: [{id: 'positive', label: 'Positive'}, {id: 'constructive', label: 'Constructive'}]
  types:          [{id: 'textarea', label: 'Large Text'}, {id: 'text', label: 'Small Text'}]
  label:          ember.computed.reads 'model.label'

  type:       ember.computed.reads 'model.type'
  type_label: ember.computed 'type', ->
    types = @get 'types'
    type  = @get 'type'
    type  = types.findBy 'id', type
    type.label

  feedback_type:       ember.computed.reads 'model.feedback_type'
  feedback_type_label: ember.computed 'feedback_type', ->
    types = @get 'feedback_types'
    type  = @get 'feedback_type'
    type  = types.findBy 'id', type
    type.label

  update_model: ->
    model     = @get('model')
    changeset = model.get('changeset')

    changeset.save() if changeset.get('isValid')
    return changeset.get('isValid')

  actions:
    back: -> @sendAction 'back'
    save: -> 
      @update_model()
      @sendAction 'back'

    update: -> 
      if @update_model()
        @sendAction('update')

    edit: ->      
      changeset = @get('changeset')
      changeset.rollback()
      @sendAction('edit', false)

    select_feedback_type: (type) ->  @set 'feedback_type', type.id
    select_type:          (type) ->  @set 'type', type.id