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
  model:  null
  index:  null
  answer: null
  
  alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  id:      ember.computed.reads 'model.id'
  label:   ember.computed.reads 'model.label'

  is_answer: ember.computed 'id', 'answer', -> parseInt(@get('id')) == parseInt(@get('answer'))

  init: ->
    @_super()

    console.lgo9'piniting choice with answer', @get('answer'), @get('id')

  init: ->
    @_super()
    console.log('initing choice with asnwer ', @get('answer'), @get('id'), parseInt(@get('answer')) == parseInt(@get('id')), @get('is_answer'))


    @init_prefix(@get('index'))
    @create_changeset()

  init_prefix: (i) ->

    console.log('calling init_prefix with index ', i)
    prefix = i%26
    prefix = @get('alphabet')[prefix]
    suffix = Math.floor(i/26)
    if suffix == 0 then suffix = ''
    result = prefix + suffix
    console.log('should be setting prefix to ', result)
    @set('prefix', result)

  create_changeset: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(true)

    changeset = totem_changeset.create(model,
      label: [vpresence]
    )
    @set('changeset', changeset)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')

      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  rollback: -> @get('changeset').rollback()

  save: ->
    console.log('calling save on choice with label ', @get('changeset.label'))
    @get('changeset').save()