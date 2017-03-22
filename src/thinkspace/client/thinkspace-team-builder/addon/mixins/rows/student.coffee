import ember from 'ember'
import util  from 'totem/util'

export default ember.Object.extend

  ## Model is set to abstract json
  model: null

  abstract: ember.computed.reads 'manager.abstract'
  teams:    ember.computed.reads 'manager.teams'

  last_name:  ember.computed.reads 'model.last_name'
  first_name: ember.computed.reads 'model.first_name'
  team_id:    ember.computed.reads 'model.team_id'

  computed_title: ember.computed 'teams', 'model', ->
    model = @get('model')
    teams = @get('teams')
    return unless ember.isPresent(teams)
    return unless ember.isPresent(model)

    team = teams.findBy('id', model.team_id)

    if ember.isPresent(team) then return team.title else return 'Unassigned'
  #computed_title: ''

  comp_title_obs: ember.observer 'teams', 'model', ->
    @init_computed_title()

  init: ->
    @init_base()
    @_super()

  init_base: ->
    #console.log('Team, Abstract ', @get('manager.teams'), @get('abstract'))
    @init_computed_title()

  init_computed_title: ->
    # console.log('[STUDENT INIT] calling init_computed_title ', @get('manager'))
    # model = @get('model')
    # teams = @get('teams')
    # return unless ember.isPresent(teams)
    # return unless ember.isPresent(model)

    # team = teams.findBy('id', model.team_id)

    # console.log('HITTING TEAM ', team)

    # if ember.isPresent(team)
    #   @set('computed_title', team.title)
    #   return team.title
    # else
    #   @set('computed_title', 'Unassigned')
    #   return 'Unassigned'
