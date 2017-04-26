import ember from 'ember'
import util  from 'totem/util'
import totem_changeset from 'totem/changeset'

###
# # choice.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend
  # ### Properties
  model:         null
  
  id:      ember.computed.reads 'model.id'
  label:   ember.computed.reads 'model.label'

  init: ->
    @_super()
    @create_changeset()

  create_changeset: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(true)

    changeset = totem_changeset.create(model,
      label: [vpresence]
    )
    @set('changeset', changeset)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')

      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  rollback: -> @get('changeset').rollback()

  save: ->
    console.log('calling save on choice with label ', @get('changeset.label'))
    @get('changeset').save()