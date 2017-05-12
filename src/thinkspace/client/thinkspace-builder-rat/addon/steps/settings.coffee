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

  create_changeset: ->
    model     = @get('model')
    changeset = totem_changeset.create model
    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  initialize: ->
    model = @get('builder.model')
    @set 'model', model
    @query_assessments().then (assessments) =>
      @set('assessments', assessments)
      @init_assessments()
      @query_phases().then =>
        @create_changeset()
        @set_all_data_loaded()

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

  query_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')

      query =
        id: model.get('id')
        componentable_type: ns.to_p('ra:assessment')
      options =
        action: 'phase_componentables'
        model: ns.to_p('ra:assessment')

      tc.query_action(ns.to_p('assignment'), query, options).then (assessments) =>
        resolve(assessments)
      , (error) => reject error

  init_assessments: ->
    assessments = @get('assessments')
    manager     = @get('manager')

    irat = assessments.findBy 'is_irat', true
    trat = assessments.findBy 'is_trat', true

    @set('irat_assessment', irat)
    @set('trat_assessment', trat)

    manager.set_assessment('irat', irat)
    manager.set_assessment('trat', trat)

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      ## Need to use an execute instead of a save here, because changeset.save proxies to the underlying object's save() fn as well
      changeset.execute()
      @get('model').save_logistics().then (saved_model) =>
        resolve(saved_model)
      , (error) => reject(error)

  select_release_at: (date) -> @get('changeset').set 'release_at', date
  select_due_at:     (date) -> @get('changeset').set 'due_at', date

  select_unlock_at: (date) -> @set('unlock_at', date)

