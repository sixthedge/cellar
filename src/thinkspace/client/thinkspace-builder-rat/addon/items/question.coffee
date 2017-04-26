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
  
  id:       ember.computed.reads 'model.id'
  question: ember.computed.reads 'model.question'
  choices:  ember.computed.reads 'model.choices'

  choice_items: ember.computed 'choices.@each', ->
    items = @get('choices')
    if ember.isPresent(items)
      @create_choice_item(item) for item in items

  create_choice_item: (item) -> choice_obj.create(model: item)

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @check_is_valid().then (valid) =>
        if valid
          @changeset_save().then =>
            resolve(true)
        else
          resolve(false)

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
    @create_changeset()

  create_changeset: ->
    model = @get('model')
    vpresence = totem_changeset.vpresence(true)
    changeset = totem_changeset.create(model,
      question: [vpresence]
    )

    @set('changeset', changeset)
  