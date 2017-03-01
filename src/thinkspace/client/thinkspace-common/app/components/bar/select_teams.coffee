import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  is_current_team: ember.computed 'selected', 'current_team', -> @get('selected') == @get('current_team')

  show_dropdown: false
  selected:      null

  dropdown_teams:  null
  prev_next_teams: null

  default_setup_options:
    include_current_team_in_dropdown:      true
    include_current_team_in_previous_next: false

  init_base: ->
    setup_options  = ember.merge {}, @default_setup_options
    @setup_options = ember.merge setup_options, @setup_options or {}
    @set_teams()

  actions:
    prev:                 -> @send 'select', @get_team_from_offset(-1)
    next:                 -> @send 'select', @get_team_from_offset(1)
    select: (team)        -> @sendAction 'select', team or @get('current_team')
    toggle_show_dropdown: -> @toggleProperty 'show_dropdown'; return

  set_teams: ->
    current_team = @get 'current_team'
    teams        = @get('teams')
    sorted_teams = teams.without(current_team).sortBy 'full_name'
    sorted_teams.unshift(current_team) if ember.isPresent(current_team)
    @set 'dropdown_teams',  if @get_setup_option('include_current_team_in_dropdown')      then sorted_teams else sorted_teams.without(current_team)
    @set 'prev_next_teams', if @get_setup_option('include_current_team_in_previous_next') then sorted_teams else sorted_teams.without(current_team)

  get_setup_option: (key) -> @setup_options and @setup_options[key]

  get_team_from_offset: (offset) ->
    current_team = @get('current_team')
    team    = @get('selected')
    teams   = @get('prev_next_teams')
    if ember.isPresent(team)
      index = teams.indexOf(team)
      switch
        when index < 0 and offset > 0  then teams.get('firstObject') # next past last
        when index < 0 and offset < 0  then teams.get('lastObject')  # prev past first
        else
          offset_team = teams.objectAt(index + offset)
          return offset_team if offset_team
          if offset > 0 then teams.get('firstObject') else teams.get('lastObject')
    else
      teams.get('firstObject')

  # # ### TESTING ONLY
  # didInsertElement: ->
  #   team = @teams.findBy 'first_name', 'read_1'
  #   @send 'select', team if team
