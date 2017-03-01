import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'viewerable'
    ta.belongs_to 'team'
  ), 

  team_id:         ta.attr('number')
  viewerable_type: ta.attr('string')
  viewerable_id:   ta.attr('number')

  # didCreate: -> @didLoad()

  # didLoad: ->
  #   @get(ta.to_p 'team').then (team) =>
  #     team.get(ta.to_p 'team_viewers').then (team_viewers) =>
  #       team_viewers.pushObject(@) unless team_viewers.contains(@)
