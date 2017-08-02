import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import v_comparison    from 'thinkspace-builder-pe/validators/comparison'
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
      release_at: [vpresence, v_comparison({initial_val: model.get('release_at'), val: 'due_at', message: 'Release date must be set before the due date', type: 'lt'})],
      due_at:     [vpresence, v_comparison({initial_val: model.get('due_at'), val: 'release_at', message: 'Release date must be set before the due date', type: 'gt'})]
    )

    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  initialize: ->
    @set('model', @get('builder.model'))
    @create_changeset() unless ember.isPresent(@get('changeset'))

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.save().then =>
        resolve()

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

