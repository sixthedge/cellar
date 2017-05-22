import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import array_helpers  from 'thinkspace-common/mixins/helpers/common/array'
import totem_scope from 'totem/scope'
import uuid from 'thinkspace-common/mixins/helpers/common/uuid'
import tc from 'totem/cache'

###
# # manager.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Service.extend array_helpers, uuid,
  ## Assessments
  irat:       null
  trat:       null
  ## Phases
  irat_phase: null
  trat_phase: null
  ## Assignment
  model:      null

  default_choices: [
    {id: 1, label: 'Choice 1'},
    {id: 2, label: 'Choice 2'},
    {id: 3, label: 'Choice 3'},
    {id: 4, label: 'Choice 4'}
  ]

  loading: null
  set_loading:      (type) -> @set("loading.#{type}", true)
  reset_loading:    (type) -> @set("loading.#{type}", false)

  initialize: (model) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set('model', model)
      @set('loading', new Object)
      @set_loading('all')
      @init_assessments().then =>
        @reset_loading('all')
        resolve()

  init_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')

      query =
        id: model.get('id')
        componentable_type: ns.to_p('ra:assessment')
      options =
        action: 'phase_componentables'
        model: ns.to_p('ra:assessment')

      tc.query_action(ns.to_p('assignment'), query, options).then (assessments) =>
        irat = assessments.findBy 'is_irat', true
        trat = assessments.findBy 'is_trat', true

        promises = 
          irat: @query_assessment_answers('irat', irat)
          trat: @query_assessment_answers('trat', trat)

        ember.RSVP.hash(promises).then (assessments_with_answers) =>
          @set_assessment('irat', assessments_with_answers.irat)
          @set_assessment('trat', assessments_with_answers.trat)
          resolve()

  ## Needed to get the assessment to serialize its answers
  query_assessment_answers: (type, assessment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment.get('authable').then (phase) =>
        @set_phase(type, phase)

        query =
          ids: ember.makeArray(assessment.get('id'))
          model: phase
          auth:
            authable_id:   phase.get('id')
            authable_type: 'Thinkspace::Casespace::Phase'

        options = 
          action: 'assessment'
          verb:   'POST'
          model:  ns.to_p('ra:assessment')
          single: true

        tc.query_action(ns.to_p("ra:#{type}"), query, options).then (result) =>
          resolve(result)


  get_default_choices: -> @duplicate_array(@get('default_choices'))
  get_items: (type)    -> @get_assessment(type).get('questions')

  set_model: (model) ->
    console.info "[rat:builder] Model set to: model"
    @set('model', model)

  set_assessment: (type, assessment) ->
    console.info "[rat:builder] Assessment set to: #{type}: #{assessment}"
    @set("#{type}", assessment)

  set_phase: (type, phase) ->
    console.info "[rat:builder] Phase set to : #{type}: #{phase}"
    @set("#{type}_phase", phase)

  ## Expects 'irat' or 'trat'
  get_assessment: (type) -> @get("#{type}")

  save_assessment: (type) ->
    assessment = @get_assessment(type)
    ## Make sure we're not persisting answers as part of the questions column
    assessment.remove_question_answers()
    assessment.save().then (saved_assessment) =>
      #@set_assessment(type, saved_assessment)
      @query_assessment_answers(type, saved_assessment).then (result) =>
        console.log('will ember data handle this result...? ', @get_assessment('irat'), result)
        totem_messages.api_success source: @, model: assessment, action: 'update', i18n_path: ns.to_o('ra:assessment', 'save')

  get_new_question_item: (type, title, choices) ->
    item =
      id:       @get_next_id(type)
      question: title || 'New question'
      choices:  @get_default_choices()
      answer:   null

  get_item_by_id: (type, id) -> @get_items(type).findBy 'id', id
  get_next_id:    (type) -> 
    assessment = @get_assessment(type)
    assessment.get('')



    @uuid()

  add_question_item: (type) ->
    item = @get_new_question_item(type)
    item.new = true
    @get_items(type).pushObject(item)
    @save_assessment(type)

  add_choice_to_item: (type, id) ->
    item   = @get_item_by_id(type, id)
    choice = @get_new_choice(item)

    item.choices.pushObject(choice)
    @save_assessment(type)

  delete_choice_from_item: (type, id, choice) ->
    item = @get_item_by_id(type, id)
    item.choices.removeObject(choice)
    @save_assessment(type)

  duplicate_question_item: (type, item) ->
    items = @get_items(type)
    index = items.indexOf(item)
    return unless index > -1
    add_at = index + 1
    return if add_at < 0
    new_item = ember.merge({}, item)
    new_item.id = @get_next_id(type)
    items.insertAt add_at, new_item

    @save_assessment(type)

  get_new_choice: (item, changeset_choices) ->
    choices        = if ember.isPresent(changeset_choices) then changeset_choices else item.choices
    sorted_choices = choices.sortBy 'id'
    last_id        = sorted_choices.get('lastObject.id')
    new_id         = last_id + 1

    choice         = {id: new_id, label: "Choice #{new_id}"}

  delete_question_item: (type, item) ->
    items = @get_items(type)
    console.log('removing item ', item, items.get('length'))
    rem_item = items.findBy 'id', item.id
    console.log('finding rem_item to remove ', rem_item)
    items.removeObject(rem_item)
    console.log('now its ', items.get('length'))
    @save_assessment(type)

  reorder_item: (type, item, offset) ->
    items = @get_items(type)
    index = items.indexOf(item)
    return unless index > -1
    switch offset
      when 1
        add_at = index + 1
      when -1
        add_at = index - 1
      when 'top'
        add_at = 0
      when 'bottom'
        add_at = items.get('length') - 1
    return if add_at < 0
    length = items.get('length')
    return if add_at > length - 1
    items.removeAt(index)
    items.insertAt(add_at, item)
    @save_assessment(type)

  get_answer_by_id: (type, id) ->
    items = @get_items(type)

  set_question_answer: (type, item_id, choice) ->
    ## Choice is an instance of the ember object 'thinkspace-builder-rat/addon/items/question/choice.coffee'
    item       = @get_item_by_id(type, item_id)
    assessment = @get_assessment(type)

    answers = if ember.isPresent(assessment.get('answers')) then assessment.get('answers') else {}
    correct_answers = if ember.isPresent(answers) and ember.isPresent(answers.correct) then answers.correct else {}
    correct_answers["#{item_id}"] = choice.get('id')

    answers.correct = correct_answers
    assessment.set('answers', answers)