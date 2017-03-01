import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  selected: ember.computed 'selected_teams.[]', -> @selected_teams.contains(@team)

  collapsed:    ember.observer 'show_all', -> @set_show_users()
  sorted_users: ember.computed -> @am.sort_users(@users)

  show_users: null

  willInsertElement: -> @set_show_users()

  set_show_users: -> @set 'show_users', @show_all

  actions:
    toggle_show_users: -> @toggleProperty('show_users'); return

    select: -> @sendAction 'select_team', @team

    select_user: (user) -> @sendAction 'select_user', @team, user
