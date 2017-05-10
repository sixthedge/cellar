import ember           from 'ember'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
import totem_changeset from 'totem/changeset'
import ta              from 'totem/ds/associations'
import totem_scope     from 'totem/scope'
import step            from './step'
import question_item   from 'thinkspace-builder-rat/items/question'

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

  sync_assessments: ember.computed.reads 'model.sync_rat_assessments'

  irat_type: 'irat'
  trat_type: 'trat'

  initialize: ->
    @reset_all_data_loaded()

    promises = 
      assessments: @query_assessments()

    @rsvp_hash_with_set(promises, @).then (results) =>
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

  toggle_assessment_sync: (val) ->
    model = @get('model')
    value = model.set_sync_assessment(val)

    model.save().then =>
      @query_assessments().then (assessments) =>
        @set('assessments', assessments)
        @init_assessments()

  irat_question_items: ember.computed 'irat_assessment.questions_with_answers.@each', ->
    items = @get('irat_assessment.questions_with_answers')
    if ember.isPresent(items)
      @create_question_item(@get('irat_type'), item) for item in items

  trat_question_items: ember.computed 'trat_assessment.questions_with_answers.@each', ->
    items = @get('trat_assessment.questions_with_answers')
    if ember.isPresent(items)
      @create_question_item(@get('trat_type'), item) for item in items

  create_question_item: (type, item) ->
    question_item.create
      model:      item
      assessment: @get('model')
      type:       type
      ## Container necessary if we want to inject the manager service
      container:  @container

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      irat_items = @get('irat_question_items')
      trat_items = @get('trat_question_items')
      items      = unless @get('sync_assessments') then irat_items.concat(trat_items) else irat_items

      promises = ember.makeArray()

      resolve() unless ember.isPresent(items)
      items.forEach (item) =>
        promises.pushObject(item.validate())

      ember.RSVP.all(promises).then (valids) =>
        resolve(!valids.contains(false))


  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate().then (validity) =>
        resolve(validity)
