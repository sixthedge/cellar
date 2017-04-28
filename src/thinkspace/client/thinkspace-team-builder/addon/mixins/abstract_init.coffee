import ember from 'ember'
import ns    from 'totem/ns'


export default ember.Mixin.create

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      resolve() unless ember.isPresent(model)
      model.get_team_sets().then (team_sets) =>
        team_set = team_sets.get('firstObject')
        resolve() unless ember.isPresent(team_set)
        @set('team_set', team_set)
        resolve(team_set)

  init_abstract: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      resolve() unless ember.isPresent(team_set)
      params =
        id: team_set.get('id')
      options =
        action: 'abstract'

      @tc.query_data(ns.to_p('team_set'), params, options).then (json) =>
        @set('abstract', json)
        resolve(json)