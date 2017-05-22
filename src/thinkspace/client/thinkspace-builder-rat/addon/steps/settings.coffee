import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
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
  manager: ember.inject.service()

  model: ember.computed.reads 'builder.model'

  irat_phase: ember.computed.reads 'manager.irat_phase'
  trat_phase: ember.computed.reads 'manager.trat_phase'

  create_changeset: ->
    console.log('changeset underlying obj is ', @get('model'))
    model     = @get('model')
    changeset = totem_changeset.create model
    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  manager_load_obs: ember.observer 'manager_loaded', ->
    if @get('manager_loaded') then @reset_loading('all')

  initialize: ->
    # model = @get('builder.model')
    # @set 'model', model
    # @query_assessments().then (assessments) =>
    #   @set('assessments', assessments)
    #   @init_assessments()
    #   @query_phases().then =>
    #     @create_changeset()
    #     @set_all_data_loaded()
    model = @get('builder.model')
    @set('model', model)
    @set_loading('all')
    @create_changeset()


  query_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>
      irat_assessment = @get('irat_assessment')
      trat_assessment = @get('trat_assessment')

      promises =
        irat: irat_assessment.get('authable')
        trat: trat_assessment.get('authable')

      ember.RSVP.hash(promises).then (results) =>
        @set('irat_phase', results.irat)
        @set('trat_phase', results.trat)
        resolve()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.save().then (model) =>
        resolve(model)
      , (error) => reject(error)

  select_release_at: (date) -> 
    console.log('trying to call select_release_at')
    @get('changeset').set 'release_at', date

  select_due_at:     (date) -> 
    console.log('trying to call select_due_at')
    @get('changeset').set 'due_at', date

