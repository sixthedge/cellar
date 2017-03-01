import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  show_all:         false
  team_member_rows: null
  columns_per_row:  ember.computed -> (ember.isPresent(@rad.width_selector) and @rad.width_selector) or 1

  init_base: -> @validate = @rad.validate

  willInsertElement: -> @setup()

  setup: ->
    @teams = @rad.get_teams() or []
    @set 'show_all', @rad.get_show_all()
    @send 'select_all' if @rad.select_all_teams()
    team_users = @rad.get_team_users()
    @set 'team_member_rows', @get_data_rows(team_users)

  actions:
    show_all: -> @set 'show_all', true
    hide_all: -> @set 'show_all', false

    select_all:   ->
      @teams.clear()
      @teams.pushObject(team.team) for team in @rad.get_team_users()
      @set_teams()

    deselect_all: ->
      @teams.clear()
      @set_teams()

    select: (team) ->
      index = @teams.indexOf(team)
      if index >= 0
        @teams.removeAt(index)
      else
        @teams.pushObject(team)
      @set_teams()

  set_teams: ->
    @rad.set_teams(@teams)
    @sendAction 'validate' if @validate
