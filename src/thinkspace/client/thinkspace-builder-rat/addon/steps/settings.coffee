import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import step            from './step'

###
# # settings.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
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
    #@load_assignment().then =>
    @create_changeset()

  # load_assignment: ->
  #   # May double load if refreshing page, but ensures that assignment is loaded (e.g. coming from templates phase).
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     model = @get 'model'
  #     console.log('model is ', model)
  #     model.get(ns.to_p('phases')).then (phases) =>
  #       console.log("phases are ", phases, phases.get('length'))
  #       resolve()
  #       # return resolve() if phases.get('length') > 0
  #       # @tc.query(ns.to_p('assignment'), {id: model.get('id'), action: 'load'}, single: true).then (assignment) =>
  #       #   resolve()

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

  select_unlock_at: (date) -> @set('unlock_at', date)

