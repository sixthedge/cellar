import ember             from 'ember'
import base              from 'thinkspace-base/components/base'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'


###
# # preview.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend changeset_helpers,

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

  display_type: null

  update_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model     = @get('model')
      changeset = model.get('changeset')
      @determine_validity(changeset).then (validity) =>
        resolve(validity)

  init_base: ->
    @init_feedback_type()

  init_feedback_type: ->
    model = @get('model')
    type  = model.get('changeset.feedback_type')
    @set('display_type', @get('feedback_types').findBy('id', type))

  actions:
    update: -> @update_model().then (valid) => @sendAction('update') if valid

    edit: ->      
      changeset = @get('changeset')
      changeset.rollback()
      @sendAction('edit', false)

    select_feedback_type: (type) ->
      @set('display_type', type)
      @set('model.changeset.feedback_type', type.id)
