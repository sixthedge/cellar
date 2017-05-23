import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
import step            from './step'
import util            from 'totem/util'

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

  sync_assessments: ember.computed.reads 'model.sync_rat_assessments'
  is_ifat:          ember.computed.reads 'irat_assessment.settings.questions.ifat'
  is_req_just:      ember.computed.reads 'irat_assessment.settings.questions.justification'

  create_changesets: ->
    model           = @get('model')
    irat_assessment = @get('irat_assessment')
    changeset       = totem_changeset.create(model)
    irat_changeset  = totem_changeset.create(irat_assessment)

    changeset.set 'show_errors', true
    irat_changeset.set('show_errors', true)
    @set('changeset', changeset)
    @set('irat_changeset', irat_changeset)

  ## API Methods

  initialize: ->
    @reset_all_data_loaded()
    model = @get('builder.model')
    @set 'model', model
    @query_assessments().then (assessments) =>
      @set('assessments', assessments)
      @init_assessments()
      @query_phases().then =>
        @create_changesets()
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

  process_changeset_strings: ->
    changeset = @get('irat_changeset')
    ## Ensure that any modifications made via text field are translated back to integers
    changeset.set('settings.scoring.correct',           parseInt(changeset.get('settings.scoring.correct')))
    changeset.set('settings.scoring.attempted',         parseInt(changeset.get('settings.scoring.attempted')))
    changeset.set('settings.scoring.no_answer',         parseInt(changeset.get('settings.scoring.no_answer')))
    changeset.set('settings.scoring.incorrect_attempt', parseInt(changeset.get('settings.scoring.incorrect_attempt')))

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset      = @get('changeset')
      irat_changeset = @get('irat_changeset')

      changeset.save().then (model) =>
        @process_changeset_strings()
        irat_changeset.save().then (results) =>
          @get('manager').save_model('irat').then =>
            resolve(model)
          , (error) => reject(error)
        , (error) => reject(error)
      , (error) => reject(error)

  toggle_is_ifat: (val) ->
    @set('is_ifat', val=='true')
    @get('irat_changeset').set('settings.questions.ifat', val=='true')
  toggle_is_req_just: (val) -> 
    @set('is_req_just', val=='true')
    @get('irat_changeset').set('settings.questions.justification', val=='true')

  select_release_at: (date) -> @get('changeset').set 'release_at', date
  select_due_at:     (date) -> @get('changeset').set 'due_at', date

