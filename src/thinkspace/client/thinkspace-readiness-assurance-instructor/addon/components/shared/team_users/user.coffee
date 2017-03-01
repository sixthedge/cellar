import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  selected: ember.computed 'selected_users.[]', -> @selected_users.contains(@user)

  collapsed: ember.observer 'show_users', 'team_selected', -> @set_show_user()

  show_user: true

  actions:
    select: ->
      @sendAction 'select', @user
      @set_show_user()

  set_show_user: ->
    if @show_users
      @set 'show_user', true
    else
      if @team_selected
        @set 'show_user', false
      else
        @set 'show_user', @get('selected')
