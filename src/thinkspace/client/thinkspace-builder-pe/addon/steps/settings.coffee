import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import vcomparison    from 'thinkspace-builder-pe/validators/comparison'
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
    vpresence = totem_changeset.vpresence(true)

    changeset = totem_changeset.create(model,
      release_at: [vpresence, vcomparison({compare_to: 'due_at',     type: 'lt', message: 'Release date must be set before the due date'})],
      due_at:     [vpresence, vcomparison({compare_to: 'release_at', type: 'gt', message: 'Due date must be set after the release date'})]
    )

    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  initialize: ->
    @set('model', @get('builder.model'))
    @create_changeset()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.save()
      @get('model').save().then (saved_model) =>
        resolve(saved_model)
      , (error) => reject(error)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  select_release_at: (date) -> 
    cs = @get('changeset')
    cs.set 'release_at', date
    cs.set 'due_at', cs.get('due_at')
    
  select_due_at: (date) -> 
    cs = @get('changeset')
    cs.set 'due_at', date
    cs.set 'release_at', cs.get('release_at')

