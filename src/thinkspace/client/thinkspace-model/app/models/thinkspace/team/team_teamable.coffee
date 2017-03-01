import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'teamable'
    ta.belongs_to 'team', reads: {}
  ), 

  team_id:       ta.attr('number')
  teamable_type: ta.attr('string')
  teamable_id:   ta.attr('number')

  # didCreate: -> @didLoad()

  # didLoad: ->
  #   @get(ta.to_p 'team').then (team) =>
  #     team.get(ta.to_p 'team_teamables').then (team_teamables) =>
  #       team_teamables.pushObject(@) unless team_teamables.contains(@)
