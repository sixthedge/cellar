import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  willInsertElement: -> @set_sorted_users()

  show_users: ember.observer 'show_all', -> @set 'collapsed', (not @get('show_all'))
  selected:   ember.computed 'selected_teams.[]', -> @selected_teams.contains(@team)

  collapsed:    true
  sorted_users: null

  actions:
    toggle_collapsed: -> @toggleProperty('collapsed'); return
    select:           -> @sendAction 'select', @team

  set_sorted_users: ->
    sorted_users = []
    if ember.isPresent(@users)
      for user in @users
        id           = user.id
        name         = @am.get_username(user)
        sorted_users.push({id, name})
    @set 'sorted_users', sorted_users.sortBy 'name'
