import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import array_helpers  from 'thinkspace-common/mixins/helpers/common/array'
import uuid from 'thinkspace-common/mixins/helpers/common/uuid'

###
# # manager.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Service.extend array_helpers, uuid,
  ## Assessments
  irat:       null
  trat:       null
  ## Assignment
  model:      null

  default_choices: [
    {id: 1, label: 'Choice 1'},
    {id: 2, label: 'Choice 2'},
    {id: 3, label: 'Choice 3'},
    {id: 4, label: 'Choice 4'}
  ]

  get_default_choices: -> @duplicate_array(@get('default_choices'))
  get_items: (type)    -> @get_assessment(type).get('questions')

  set_model: (model) ->
    console.info "[rat:builder] Model set to: model"
    @set('model', model)

  set_assessment: (type, assessment) ->
    console.info "[rat:builder] Assessment set to: #{type}: #{assessment}"
    @set("#{type}", assessment)

  ## Expects 'irat' or 'trat'
  get_assessment: (type) -> @get("#{type}")

  ## TODO refactor this to 'save_assessment' or something similar
  save_model: (type) ->
    model = @get_assessment(type)
    model.save().then =>
      totem_messages.api_success source: @, model: model, action: 'update', i18n_path: ns.to_o('ra:assessment', 'save')

  get_new_question_item: (type, title, choices) ->
    item =
      id:       @get_next_id(type)
      question: title || 'New question'
      choices:  @get_default_choices()
      answer:   null

  get_item_by_id: (type, id) -> @get_items(type).findBy 'id', id
  get_next_id:    (type) -> @uuid()

  add_question_item: (type) ->
    item = @get_new_question_item(type)
    item.new = true
    @get_items(type).pushObject(item)
    @save_model(type)

  add_choice_to_item: (type, id) ->
    item   = @get_item_by_id(type, id)
    choice = @get_new_choice(item)

    item.choices.pushObject(choice)
    @save_model(type)

  delete_choice_from_item: (type, id, choice) ->
    item = @get_item_by_id(type, id)
    item.choices.removeObject(choice)
    @save_model(type)

  duplicate_question_item: (type, item) ->
    items = @get_items(type)
    index = items.indexOf(item)
    return unless index > -1
    add_at = index + 1
    return if add_at < 0
    new_item = ember.merge({}, item)
    new_item.id = @get_next_id(type)
    items.insertAt add_at, new_item

    @save_model(type)

  get_new_choice: (item, changeset_choices) ->
    choices        = if ember.isPresent(changeset_choices) then changeset_choices else item.choices
    sorted_choices = choices.sortBy 'id'
    last_id        = sorted_choices.get('lastObject.id')
    new_id         = last_id + 1

    choice         = {id: new_id, label: "Choice #{new_id}"}

  delete_question_item: (type, item) ->
    items = @get_items(type)
    items.removeObject(item)
    @save_model(type)

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
    @save_model(type)

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