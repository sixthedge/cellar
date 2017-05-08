import ember           from 'ember'
import util            from 'totem/util'
import totem_changeset from 'totem/changeset'
import choice_obj      from 'thinkspace-builder-rat/items/question/choice'

###
# # question.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend
  # ### Properties
  model:         null

  manager: ember.inject.service()
  
  id:       ember.computed.reads 'model.id'
  question: ember.computed.reads 'model.question'
  choices:  ember.computed.reads 'model.choices'
  answer:   ember.computed.reads 'model.answer'

  choice_items: ember.computed 'changeset.choices.@each', ->
    choice_items = ember.makeArray()
    items        = @get('choices')
    if ember.isPresent(items)
      items.forEach (item, index) =>
        item = @create_choice_item(item, index)
        choice_items.pushObject(item)
    choice_items

  create_choice_item: (item, index) -> choice_obj.create(model: item, index: index, answer: @get('answer'))

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @check_is_valid().then (valid) =>
        if valid
          @changeset_save().then =>
            resolve(true)
        else
          resolve(false)

  select_answer: (choice) ->
    @get('manager').set_question_answer(@get('type'), @get('model.id'), choice)
    @get('changeset').set('answer', choice.get('model.id'))
    #@process_choices(@get('choice_items'))

  check_is_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      validities   = ember.makeArray()
      choice_items = @get('choice_items')

      validities.pushObject(@validate_changeset())

      choice_items.forEach (choice) =>
        validities.pushObject(choice.validate())

      ember.RSVP.all(validities).then (valids) =>
        resolve(!valids.contains(false))

  changeset_save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      choice_items = @get('choice_items')
      changeset    = @get('changeset')

      promises = ember.makeArray()
      promises.pushObject(changeset.save())
      choice_items.forEach (choice) =>
        promises.pushObject(choice.save())

      ember.RSVP.all(promises).then =>
        resolve()
      , (error) =>
        reject(error)

  changeset_rollback: ->
    new ember.RSVP.Promise (resolve, reject) =>
      choice_items = @get('choice_items')
      changeset = @get('changeset')

      promises = ember.makeArray()
      promises.pushObject(changeset.rollback())
      choice_items.forEach (choice) =>
        promises.pushObject(choice.rollback())
      ember.RSVP.all(promises).then =>
        resolve()
      , (error) =>
        reject(error)

  validate_changeset: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  init: ->
    @_super()
    console.log('creating question with model ', @get('model'), @get('answer'))

    @create_changeset()

  create_changeset: ->
    model = @get('model')
    console.log('creatign_changeset for model ', model)
    vpresence = totem_changeset.vpresence(true)
    changeset = totem_changeset.create(model,
      question: [vpresence],
      answer:   [vpresence],
      choices:  [vpresence]
    )

    @set('changeset', changeset)

  add_choice_to_item: (type, item_id) ->
    console.log('[QUESTION OBJ] calling add_choice_to_item with ', type, item_id)
    item   = @get('manager').get_item_by_id(type, item_id)
    choice = @get('manager').get_new_choice(item)
    console.log('PRE ', @get('changeset.choices.length'))
    @get('changeset.choices').pushObject(choice)
    console.log('POST ', @get('changeset.choices.length'))


  delete_choice_from_item: (type, item_id, choice) ->
    console.log('[QUESTION_OBJ] calling delete_choice_from_item with ', type, item_id, choice)
  