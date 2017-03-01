import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'user', reads: {}
    ta.belongs_to 'team', reads: {}
  ), 

  user_id: ta.attr('number')
  team_id: ta.attr('number')

  # didCreate: -> @didLoad()

  # didLoad: ->
  #   @get(ta.to_p 'team').then (team) =>
  #     team.get(ta.to_p 'team_users').then (team_users) =>
  #       team_users.pushObject(@) unless team_users.contains(@)
