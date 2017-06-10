import ember from 'ember'
import step  from './step'
import ta              from 'totem/ds/associations'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import tc              from 'totem/cache'

###
# # details.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default step.extend

  id: 'details'
  index: 0
  route_path: 'details'

  builder: ember.inject.service()
  manager: ember.inject.service()

  model:           ember.computed.reads 'builder.model'

  irat_phase:      ember.computed.reads 'manager.irat_phase'
  trat_phase:      ember.computed.reads 'manager.trat_phase'
  irat_assessment: ember.computed.reads 'manager.irat'
  trat_assessment: ember.computed.reads 'manager.trat'

  create_changesets: ->
    model      = @get('model')
    vpresence  = totem_changeset.vpresence(presence: true)
    vlength    = totem_changeset.vlength(min: 4)
    irat_phase = @get('irat_phase')
    trat_phase = @get('trat_phase')
    
    changeset = totem_changeset.create model,
      title:        [vpresence, vlength]
      instructions: [vpresence]
    
    irat_changeset = totem_changeset.create(irat_phase)
    trat_changeset = totem_changeset.create(trat_phase)

    @set 'irat_changeset', irat_changeset
    @set 'trat_changeset', trat_changeset
    @set 'changeset', changeset

  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_loading('all')
      @create_changesets()
      @init_phase_titles()
      @reset_loading('all')
      resolve()

  init_phase_titles: ->
    @init_phase_title('irat', @get('irat_phase'))
    @init_phase_title('trat', @get('trat_phase'))

  init_phase_title: (type, phase) -> @set("#{type}_changeset.title", '') unless ember.isPresent(phase.get('title'))

  persist_phase_titles: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @persist_phase_title('irat', @get('irat_phase'))
      @persist_phase_title('trat', @get('trat_phase'))
      @get('irat_changeset').save().then =>
        @get('trat_changeset').save().then =>
          resolve()

  persist_phase_title: (type, phase) ->
    changeset = @get("#{type}_changeset")
    unless ember.isPresent(changeset.get('title'))
      changeset.set('title', @get_default_phase_title(type))

  get_default_phase_title: (type) -> 
    suffix = if type == 'irat' then 'iRAT' else 'tRAT'
    return @get('changeset.title') + ' - ' + suffix

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      @validate().then (valid) =>
        if valid
          changeset.save().then =>
            @persist_phase_titles().then =>
              @get('model').save().then (saved_model) =>
                resolve(saved_model)
              , (error) => reject(error)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.validate().then =>
        resolve(changeset.get('isValid'))
