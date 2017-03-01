import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  show_all:         false
  team_member_rows: null
  columns_per_row:  ember.computed -> (ember.isPresent(@rad.width_selector) and @rad.width_selector) or 1
  column_width:     300

  init_base: -> @validate = @rad.validate

  willInsertElement: -> @setup()

  setup: ->
    @teams      = @rad.get_teams() or []
    @users      = @rad.get_users() or []
    @team_users = @rad.get_team_users()
    @set 'show_all', @rad.get_show_all()
    @send 'select_all' if @rad.select_all_users()
    @set 'team_users_rows', @get_data_rows(@team_users)

  actions:
    show_all:   -> @set 'show_all', true
    hide_all:   -> @set 'show_all', false

    select_all:   ->
      @teams.clear()
      @users.clear()
      for team_users in @team_users
        @teams.pushObject(team_users.team)
        @users.pushObject(user) for user in team_users.users
      @set_users()

    deselect_all: ->
      @teams.clear()
      @users.clear()
      @set_users()

    select_team: (team) ->
      index = @teams.indexOf(team)
      if index >= 0
        @teams.removeAt(index)
        @remove_team_users(team)
      else
        @teams.pushObject(team)
        @add_team_users(team)
      @set_users()

    select_user: (team, user) ->
      @remove_team(team)
      index = @users.indexOf(user)
      if index >= 0
        @users.removeAt(index)
      else
        @users.pushObject(user)
        @add_team(team) if @all_team_users_selected(team)
      @set_users()

  set_users: ->
    @rad.set_users(@users)
    @sendAction 'validate' if @validate

  get_users_for_team: (team) ->
    team_users = @team_users.find (tu) => tu.team.id == team.id
    if ember.isBlank(team_users) then [] else team_users.users

  add_team: (team) ->
    index = @teams.indexOf(team)
    @teams.pushObject(team) unless index >= 0

  remove_team: (team) ->
    index = @teams.indexOf(team)
    @teams.removeAt(index) if index >= 0

  add_team_users: (team) ->
    for user in @get_users_for_team(team)
      @users.pushObject(user) unless @users.contains(user)

  remove_team_users: (team) ->
    for user in @get_users_for_team(team)
      index = @users.indexOf(user)
      @users.removeAt(index) if index >= 0

  all_team_users_selected: (team) ->
    for user in @get_users_for_team(team)
      return false unless @users.contains(user)
    true

