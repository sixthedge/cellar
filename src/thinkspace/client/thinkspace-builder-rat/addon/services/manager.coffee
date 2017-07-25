import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import array_helpers  from 'thinkspace-common/mixins/helpers/common/array'
import totem_scope    from 'totem/scope'
import tc             from 'totem/cache'
import util           from 'totem/util'

###
# # manager.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Service.extend array_helpers,
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

  default_sync_options: {
    questions: 'all',
    answers:   'all',
    transform: 'all',
    settings: 
      next_id: true
      scoring:
        only: ['correct', 'no_answer']
      questions:
        only: ['justification']
  }

  has_transform:      ember.computed 'has_irat_transform', 'has_trat_transform', -> @get('has_irat_transform') || @get('has_trat_transform')
  
  has_irat_transform: ember.computed.notEmpty 'irat.transform'
  has_trat_transform: ember.computed.notEmpty 'trat.transform'

  ## Reconciliation varable
  irat_questions_column: ember.computed 'irat.transform', -> @get_column('irat', 'questions')
  irat_settings_column:  ember.computed 'irat.transform', -> @get_column('irat', 'settings')
  irat_answers_column:   ember.computed 'irat.transform', -> @get_column('irat', 'answers')

  #trat_questions_column: ember.computed 'trat_assessment.transform', -> @get_column('trat', 'questions')
  #trat_settings_column:  ember.computed 'trat_assessment.transform', -> @get_column('trat', 'settings')
  #trat_answers_column:   ember.computed 'trat_assessment.transform', -> @get_column('trat', 'answers')

  get_column: (type, col) ->
    console.log('get_column isPresent? ', @get('irat'), type, col, @get("{type}.transform"))

    if ember.isPresent(@get("#{type}.transform")) 
      "transform.#{col}" 
    else 
      col

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

        console.log('init_assessments ', irat, trat)

        promises = 
          irat: @query_assessment_answers('irat', irat)
          trat: @query_assessment_answers('trat', trat)

        ember.RSVP.hash(promises).then (assessments_with_answers) =>
          @set_assessment('irat', assessments_with_answers.irat)
          @set_assessment('trat', assessments_with_answers.trat)
          resolve()

  update_question: (type, question) ->
    items = @get_items(type)
    item  = items.findBy('id', question.get('id'))
    ember.set(item, 'choices', question.get('choices'))
    ember.set(item, 'question', question.get('question'))    

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

  query_assessment_sync: (type, assessment, options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase = @get_phase(type)

      options = unless ember.isPresent(options) then @get('default_sync_options') else options

      query =
        id: assessment.get('id')
        model: assessment
        data:
          attributes:
            options: options

        auth:
          authable_id: phase.get('id')
          authable_type: 'Thinkspace::Casespace::Phase'

      options =
        action: 'sync'
        verb: 'POST'
        model: ns.to_p('ra:assessment')

      tc.query_action(ns.to_p('ra:assessment'), query, options).then (result) =>
        resolve()

  set_model: (model) ->
    console.info "[rat:builder] Model set to: model"
    @set('model', model)

  set_assessment: (type, assessment) ->
    console.info "[rat:builder] Assessment set to: #{type}: #{assessment}"
    @set("#{type}", assessment)

  set_phase: (type, phase) ->
    console.info "[rat:builder] Phase set to : #{type}: #{phase}"
    @set("#{type}_phase", phase)

  get_phase: (type) -> @get("#{type}_phase")

  save_assessment: (type) ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment = @get_assessment(type)
      ## Make sure we're not persisting answers as part of the questions column
      assessment.remove_question_answers()
      assessment.save().then (saved_assessment) =>
        @query_assessment_answers(type, saved_assessment).then (result) =>
          @query_assessment_sync(type, result).then =>
            totem_messages.api_success source: @, model: assessment, action: 'update', i18n_path: ns.to_o('ra:assessment', 'save')
            resolve()

  get_new_question_item: (type, title, choices) ->
    item =
      id:       @get_next_id(type)
      question: title || 'New question'
      choices:  @get_default_choices()
      answer:   null

  ## Expects 'irat' or 'trat'
  get_assessment:   (type)     -> @get("#{type}")
  get_item_by_id:   (type, id) -> @get_items(type).findBy 'id', id
  get_next_id:      (type)     -> @get_assessment(type).get(@get_column(type, 'settings.next_id')).toString()
  get_default_choices:         -> @duplicate_array(@get('default_choices'))
  get_items:        (type)     -> @get_assessment(type).get(@get_column(type, 'questions'))
  # get_answer_by_id: (type, id) -> items = @get_items(type)

  increment_next_id: (type) -> 
    assessment = @get_assessment(type)
    cur = assessment.get(@get_column(type, 'settings.next_id'))
    #cur = assessment.get('settings.next_id')
    next = if ember.isPresent(cur) then cur + 1 else 0
    util.set_path_value(assessment, @get_column(type, 'settings.next_id'), next)

  add_question_item: (type) ->
    new ember.RSVP.Promise (resolve, reject) =>
      item = @get_new_question_item(type)
      @get_items(type).pushObject(item)
      assessment = @get_assessment(type)

      @increment_next_id(type)
      @save_assessment(type).then =>
        resolve(item)

  add_choice_to_item: (type, id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      item   = @get_item_by_id(type, id)
      choice = @get_new_choice(item)

      item.choices.pushObject(choice)
      @save_assessment(type).then =>
        resolve()

  delete_choice_from_item: (type, id, choice) ->
    new ember.RSVP.Promise (resolve, reject) =>
      item = @get_item_by_id(type, id)
      item.choices.removeObject(choice)
      @save_assessment(type).then =>
        resolve()

  duplicate_question_item: (type, item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      items = @get_items(type)
      item  = items.findBy('id', item.id)
      index = items.indexOf(item)
      resolve() unless index > -1
      add_at = index + 1
      resolve() if add_at < 0
      new_item = ember.merge({}, item)
      new_item.id = @get_next_id(type)
      items.insertAt add_at, new_item
      ans = @get_item_answer(type, item)
      @set_question_answer(type, new_item.id, ans)
      @increment_next_id(type)
      @save_assessment(type).then =>
        resolve()

  get_answers: (type) -> @get_assessment(type).get(@get_column(type, 'answers'))

  get_item_answer: (type, item) ->
    answers = @get_answers(type)
    return unless ember.isPresent(answers)
    return unless ember.isPresent(answers.correct)
    return unless ember.isPresent(answers.correct["#{item.id}"])
    return answers.correct["#{item.id}"]

  get_answer_by_id: (type, id) ->
    answers = @get_answers(type)

    return unless ember.isPresent(answers)
    return unless ember.isPresent(answers.correct)
    return unless ember.isPresent(answers.correct[id])
    return answers.correct[id]

  get_new_choice: (item, changeset_choices) ->
    choices        = if ember.isPresent(changeset_choices) then changeset_choices else item.choices
    sorted_choices = choices.sortBy 'id'
    last_id        = sorted_choices.get('lastObject.id')
    new_id         = last_id + 1
    choice         = {id: new_id, label: "Choice #{new_id}"}

  delete_question_item: (type, item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      items    = @get_items(type)
      rem_item = items.findBy 'id', item.id
      items.removeObject(rem_item)
      @delete_question_answer(type, item.id)
      @save_assessment(type).then =>
        resolve()

  reorder_item: (type, item, offset) ->
    new ember.RSVP.Promise (resolve, reject) =>
      items   = @get_items(type)
      re_item = items.findBy 'id', item.id
      index   = items.indexOf(re_item)
      return reject() unless index > -1
      switch offset
        when 1
          add_at = index + 1
        when -1
          add_at = index - 1
        when 'top'
          add_at = 0
        when 'bottom'
          add_at = items.get('length') - 1
      return reject() if add_at < 0
      length = items.get('length')
      return reject() if add_at > length - 1
      items.removeAt(index)
      items.insertAt(add_at, re_item)
      @save_assessment(type).then =>
        resolve()

  delete_question_answer: (type, item_id) ->
    item = @get_item_by_id(type, item_id)
    assessment = @get_assessment(type)

    answers         = if ember.isPresent(assessment.get(@get_column(type, 'answers'))) then assessment.get(@get_column(type, 'answers')) else {}
    correct_answers = if ember.isPresent(answers) and ember.isPresent(answers.correct) then answers.correct else {}
    delete correct_answers["#{item_id}"] if ember.isPresent(correct_answers["#{item_id}"])

  set_question_answer: (type, item_id, choice_id) ->
    ## Choice is an instance of the ember object 'thinkspace-builder-rat/addon/items/question/choice.coffee'
    item       = @get_item_by_id(type, item_id)
    assessment = @get_assessment(type)

    answers = if ember.isPresent(assessment.get(@get_column(type, 'answers'))) then assessment.get(@get_column(type, 'answers')) else {}
    correct_answers = if ember.isPresent(answers) and ember.isPresent(answers.correct) then answers.correct else {}
    correct_answers["#{item_id}"] = choice_id

    answers.correct = correct_answers
    util.set_path_value(assessment, @get_column(type, 'answers'), answers)