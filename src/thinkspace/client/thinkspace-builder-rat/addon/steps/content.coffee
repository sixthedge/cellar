import ember           from 'ember'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
import totem_changeset from 'totem/changeset'
import ta              from 'totem/ds/associations'
import totem_scope     from 'totem/scope'
import step            from './step'

###
# # content.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default step.extend

  id: 'content'
  index: 1
  route_path: 'content'

  builder: ember.inject.service()
  manager: ember.inject.service()

  model: ember.computed.reads 'builder.model'

  sync_assessments: ember.computed.reads 'model.settings.rat.sync'

  initialize: ->
    @reset_all_data_loaded()

    promises = 
      assessments: @query_assessments()

    @rsvp_hash_with_set(promises, @).then (results) =>
      @get('manager')
      @init_assessments()

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

  toggle_assessment_sync: ->
    model = @get('model')
    value = model.set_sync_assessment(!@get('sync_assessments'))

    model.save().then =>
      @query_assessments().then (assessments) =>
        @set('assessments', assessments)
        @init_assessments()
