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

  model: ember.computed.reads 'builder.model'

  initialize: ->
    console.log('[RAT] calling content initialize ', @get('builder'), @get('builder.model'))
    @reset_all_data_loaded()

    promises = 
      assessments: @query_assessments()

    @rsvp_hash_with_set(promises, @).then (results) =>
      @init_assessments()
      console.log('[RAT] assessments? ', results.assessments, results.assessments.get('length'))

  query_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      console.log("model is ", model)

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

    irat = assessments.findBy 'is_irat', true
    trat = assessments.findBy 'is_trat', true

    console.log('irat is ', irat)
    console.log('trat is ', trat)
