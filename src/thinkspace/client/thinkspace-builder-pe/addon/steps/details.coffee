import ember           from 'ember'
import tc              from 'totem/cache'
import ns              from 'totem/ns'
import totem_changeset from 'totem/changeset'
import step            from './step'
import ta              from 'totem/ds/associations'

###
# # details.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-pe**
###
export default step.extend

  id: 'details'
  index: 0
  route_path: 'details'

  builder: ember.inject.service()

  assignment: ember.computed.reads 'manager.assignment'
  team_set:   ember.computed.reads 'manager.team_set'

  create_changeset: ->
    model     = @get('model')
    console.log('calling create_changeset')

    vpresence = totem_changeset.vpresence(presence: true)
    vlength   = totem_changeset.vlength(min: 4)

    changeset = totem_changeset.create model,
      title:        [vpresence, vlength]
      instructions: [vpresence]

    changeset.set 'show_errors', true
    @set 'changeset', changeset

  ## API Methods

  init_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises =
        assignment: @load_assignment_data()
        team_set:   @query_team_sets()
        #phases:     @query_phases()

      ember.RSVP.hash(promises).then (results) =>
        resolve(results)

  initialize: ->
    @initialize_team_set().then (team_set) =>
      @create_changeset()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.save()
      @get('model').save().then (saved_model) =>
        resolve(saved_model)
      , (error) => reject(error)

  load_assignment_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      params = 
        id: @get('model.id')
      options =
        action: 'load'
        model:  ta.to_p('assignment')
      tc.query_action(ta.to_p('assignment'), params, options).then (assignment) =>
        resolve (assignment)

  query_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model').get(ta.to_p('space')).then (space) =>
        space.get_default_team_set().then (team_set) =>
          @set 'team_sets', ember.makeArray(team_set)
          resolve(team_set)

  select_team_set: (team_set) -> 
    @set 'selected_team_set', team_set
    @get('model').get(ta.to_p('phases')).then (phases) =>
      phase = phases.get('firstObject')
      phase.set 'team_set_id', team_set.get('id')
      phase.save()

  initialize_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model').get(ta.to_p('phases')).then (phases) =>
        team_sets = @get('team_sets')
        phase     = phases.get('firstObject')
        if ember.isPresent(phase.get('team_set_id')) 
          team_set = team_sets.findBy 'id', phase.get('team_set_id').toString()
          @set 'selected_team_set', team_set
        else 
          team_set = team_sets.get('firstObject')
          @select_team_set team_set
        resolve()
