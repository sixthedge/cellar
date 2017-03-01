import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import step            from './step'

###
# # settings.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-pe**
###
export default step.extend

  id: 'settings'
  index: 2
  route_path: 'settings'

  builder: ember.inject.service()

  create_changeset: ->
    model     = @get('model')
    changeset = totem_changeset.create model
    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  initialize: ->
    model = @get('builder.model')
    @set 'model', model
    @create_changeset()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.save()
      @get('model').save().then (saved_model) =>
        @get('model').save_logistics().then (saved_model) =>
          resolve(saved_model)
        , (error) => reject(error)
      , (error) => reject(error)

  select_release_at: (date) -> @get('changeset').set 'release_at', date
  select_due_at: (date) -> @get('changeset').set 'due_at', date

