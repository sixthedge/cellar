import ember             from 'ember'
import totem_changeset   from 'totem/changeset'
import ns                from 'totem/ns'
import tc                from 'totem/cache'
import step              from './step'
import util              from 'totem/util'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'

###
# # settings.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default step.extend changeset_helpers,

  id: 'settings'
  index: 2
  route_path: 'settings'

  builder: ember.inject.service()
  manager: ember.inject.service()

  model: ember.computed.reads 'builder.model'

  irat_phase:       ember.computed.reads 'manager.irat_phase'
  trat_phase:       ember.computed.reads 'manager.trat_phase'

  irat_assessment:  ember.computed.reads 'manager.irat'
  trat_assessment:  ember.computed.reads 'manager.trat'

  sync_assessments: ember.computed.reads 'model.sync_rat_assessments'
  is_ifat:          ember.computed.reads 'irat_assessment.settings.questions.ifat'
  is_req_just:      ember.computed.reads 'irat_assessment.settings.questions.justification'

  create_changesets: ->
    model           = @get('model')
    irat_assessment = @get('irat_assessment')

    v_integer  = totem_changeset.vnumber({integer: true})
    v_positive = totem_changeset.vnumber({positive: true})
    v_presence = totem_changeset.vpresence(true)

    changeset       = totem_changeset.create(model)
    irat_changeset  = totem_changeset.create(irat_assessment)

    scoring_changeset = totem_changeset.create(irat_assessment.get('settings.scoring'),
      correct:           [v_integer, v_presence, v_positive],
      no_answer:         [v_integer, v_presence],
      attempted:         [v_integer, v_presence, v_positive],
      incorrect_attempt: [v_integer, v_presence, v_positive]
    )

    @init_incorrect_attempt(scoring_changeset)

    changeset.set('show_errors', true)
    irat_changeset.set('show_errors', true)
    @set('changeset', changeset)
    @set('irat_changeset', irat_changeset)
    @set('scoring_changeset', scoring_changeset)

  ## API Methods

  init_incorrect_attempt: (cs) ->
    incorrect_attempt = cs.get('incorrect_attempt')
    cs.set('incorrect_attempt', incorrect_attempt * -1)

  register_phase_changeset: (type, changeset) -> @set("#{type}_phase_cs", changeset)

  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @create_changesets()
      @reset_loading('all')
      resolve()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      cs            = @get('changeset')
      irat_cs       = @get('irat_changeset')
      scoring_cs    = @get('scoring_changeset')
      irat_phase_cs = @get('irat_phase_cs')
      trat_phase_cs = @get('trat_phase_cs')

      ## Need to proceed by:
      ## => 1. Make sure that scoring_changeset is valid
      ## => 2. if valid, manually set those values to the irat_changeset (need to use the scoring_changeset to allow validations to function)
      ## => 3. execute the irat_changeset to persist changes to the assessment
      ## => 4. execute the changes to the phases(?)

      validated_cs = [scoring_cs, irat_phase_cs, trat_phase_cs]
      @determine_validity(validated_cs).then (step_valid) =>
        if step_valid
          scoring_cs.save().then =>
            @persist_scoring()
            irat_cs.save().then =>
              irat_phase_cs.save().then =>
                trat_phase_cs.save().then =>
                  @persist_assignment_dates()
                  cs.save().then =>
                    resolve()

  process_changeset_strings: ->
    changeset = @get('irat_changeset')
    ## Ensure that any modifications made via text field are translated back to integers
    changeset.set('settings.scoring.correct',           parseInt(changeset.get('settings.scoring.correct')))
    changeset.set('settings.scoring.attempted',         parseInt(changeset.get('settings.scoring.attempted')))
    changeset.set('settings.scoring.no_answer',         parseInt(changeset.get('settings.scoring.no_answer')))
    changeset.set('settings.scoring.incorrect_attempt', parseInt(changeset.get('settings.scoring.incorrect_attempt')))

  persist_scoring: ->
    scoring_cs = @get('scoring_changeset')
    irat_cs    = @get('irat_changeset')
    irat_cs.set('settings.scoring.correct', scoring_cs.get('correct'))
    irat_cs.set('settings.scoring.attempted', scoring_cs.get('attempted'))
    irat_cs.set('settings.scoring.no_answer', scoring_cs.get('no_answer'))
    irat_cs.set('settings.scoring.incorrect_attempt', scoring_cs.get('incorrect_attempt') * -1)
    @process_changeset_strings()

  persist_assignment_dates: ->
    irat_phase = @get('irat_phase')
    trat_phase = @get('trat_phase')
    changeset  = @get('changeset')

    unlock_at = if irat_phase.get('unlock_at') <= trat_phase.get('unlock_at') then irat_phase.get('unlock_at') else trat_phase.get('unlock_at')
    due_at    = if irat_phase.get('due_at')    >= trat_phase.get('due_at')    then irat_phase.get('due_at')    else trat_phase.get('due_at')

    changeset.set('release_at', unlock_at)
    changeset.set('due_at',     due_at)

  toggle_irat_changeset_property: (property) ->
    changeset = @get('irat_changeset')
    changeset.toggleProperty(property)
    @propertyDidChange('irat_changeset')

  ## When we toggle the visibility of the ifat-dependent fields, we want to make sure we aren't validating changes to fields that aren't present
  reset_changeset_values: (path) ->
    scoring_cs = @get('scoring_changeset')
    irat_cs    = @get('irat_changeset')
    reset      = irat_cs.get("#{path}")
    if !reset
      scoring_cs.set('attempted',         irat_cs.get('settings.scoring.attempted'))
      scoring_cs.set('incorrect_attempt', irat_cs.get('settings.scoring.incorrect_attempt'))

  toggle_is_ifat:     -> 
    @toggle_irat_changeset_property('settings.questions.ifat')
    @reset_changeset_values('settings.questions.ifat')

  toggle_is_req_just: -> @toggle_irat_changeset_property('settings.questions.justification')

  select_release_at: (date) -> @get('changeset').set 'release_at', date
  select_due_at:     (date) -> @get('changeset').set 'due_at', date
