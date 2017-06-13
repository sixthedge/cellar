import ember from 'ember'
import util  from 'totem/util'
import totem_changeset from 'totem/changeset'

###
# # choice.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend
  # ### Properties
  model:    null
  index:    null
  question: null
  
  alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  id:      ember.computed.reads 'model.id'
  label:   ember.computed.reads 'model.label'
  answer:  ember.computed.reads 'question.answer_cs.answer'

  is_answer: ember.computed 'id', 'answer', 'model', -> parseInt(@get('id')) == parseInt(@get('answer'))

  init: ->
    @_super()
    @init_prefix(@get('index'))
    @create_changeset()

  init_prefix: (i) ->
    i = @get('index') unless ember.isPresent(i)
    prefix = i%26
    prefix = @get('alphabet')[prefix]
    suffix = Math.floor(i/26)
    if suffix == 0 then suffix = ''
    result = prefix + suffix
    @set('prefix', result)

  create_changeset: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(true)
    changeset = totem_changeset.create(model, label: [vpresence])

    @set('changeset', changeset)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')

      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  rollback: -> @get('changeset').rollback()
  save:     -> @get('changeset').save()