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

  create_changeset: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(presence: true)
    vlength   = totem_changeset.vlength(min: 4)

    changeset = totem_changeset.create model,
      title:        [vpresence, vlength]
      instructions: [vpresence]
    @set 'changeset', changeset


  initialize: ->
    model = @get('builder.model')
    @set 'model', model
    @create_changeset()
    @load_assignment_data().then (assignment) =>
      @query_team_sets().then (team_sets) =>
        @initialize_team_set().then (team_set) =>
          @set_all_data_loaded()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      @validate().then (valid) =>
        if valid
          changeset.save().then =>
            @get('model').save().then (saved_model) =>
              resolve(saved_model)
            , (error) => reject(error)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  load_assignment_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      params = 
        id: @get('model.id')
      options =
        action: 'load'
        model:  ta.to_p('assignment')
      tc.query_action(ta.to_p('assignment'), params, options).then (assignment) =>
        resolve assignment

  query_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model').get(ta.to_p('space')).then (space) =>
        space.get_team_sets().then (team_sets) =>
          @set 'team_sets', team_sets
          resolve()

  select_team_set: (team_set) -> 
    # TODO: This needs to be refactored to get the tRAT assessment, then get the authable for it.
    @set 'selected_team_set', team_set
    @get('model').get(ta.to_p('phases')).then (phases) =>
      phase = phases.get('lastObject')
      phase.set 'team_set_id', team_set.get('id')
      phase.save()

  initialize_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model').get(ta.to_p('phases')).then (phases) =>
        team_sets   = @get('team_sets')
        phase       = phases.get('firstObject')
        if ember.isPresent(phase.get('team_set_id')) 
          team_set = team_sets.findBy 'id', phase.get('team_set_id').toString()
          @set 'selected_team_set', team_set
        else 
          team_set = team_sets.get('firstObject')
          @select_team_set team_set
        resolve()
