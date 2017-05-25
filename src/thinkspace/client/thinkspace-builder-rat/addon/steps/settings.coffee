import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
import step            from './step'
import util            from 'totem/util'

###
# # settings.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default step.extend

  id: 'settings'
  index: 2
  route_path: 'settings'

  builder: ember.inject.service()
  manager: ember.inject.service()

  model: ember.computed.reads 'builder.model'

  irat_phase: ember.computed.reads 'manager.irat_phase'
  trat_phase: ember.computed.reads 'manager.trat_phase'

  sync_assessments: ember.computed.reads 'model.sync_rat_assessments'
  is_ifat:          ember.computed.reads 'irat_assessment.settings.questions.ifat'
  is_req_just:      ember.computed.reads 'irat_assessment.settings.questions.justification'

  create_changesets: ->
    model           = @get('model')
    irat_assessment = @get('irat_assessment')
    changeset       = totem_changeset.create(model)
    irat_changeset  = totem_changeset.create(irat_assessment)

    changeset.set('show_errors', true)
    irat_changeset.set('show_errors', true)
    @set('changeset', changeset)
    @set('irat_changeset', irat_changeset)

  ## API Methods

  manager_load_obs: ember.observer 'manager_loaded', ->
    if @get('manager_loaded') then @reset_loading('all')

  initialize: ->
    @set_loading('all')
    @create_changesets()
    @reset_loading('all')

  process_changeset_strings: ->
    changeset = @get('irat_changeset')
    ## Ensure that any modifications made via text field are translated back to integers
    changeset.set('settings.scoring.correct',           parseInt(changeset.get('settings.scoring.correct')))
    changeset.set('settings.scoring.attempted',         parseInt(changeset.get('settings.scoring.attempted')))
    changeset.set('settings.scoring.no_answer',         parseInt(changeset.get('settings.scoring.no_answer')))
    changeset.set('settings.scoring.incorrect_attempt', parseInt(changeset.get('settings.scoring.incorrect_attempt')))

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset      = @get('changeset')
      irat_changeset = @get('irat_changeset')

      changeset.save().then (model) =>
        @process_changeset_strings()
        irat_changeset.save().then (results) =>
          @get('manager').save_model('irat').then =>
            resolve(model)
          , (error) => reject(error)
        , (error) => reject(error)
      , (error) => reject(error)

  toggle_irat_changeset_property: (property) ->
    changeset = @get('irat_changeset')
    changeset.toggleProperty(property)
    @propertyDidChange('irat_changeset')

  toggle_is_ifat:     -> @toggle_irat_changeset_property('settings.questions.ifat')
  toggle_is_req_just: -> @toggle_irat_changeset_property('settings.questions.justification')

  select_release_at: (date) -> @get('changeset').set 'release_at', date
  select_due_at:     (date) -> @get('changeset').set 'due_at', date
