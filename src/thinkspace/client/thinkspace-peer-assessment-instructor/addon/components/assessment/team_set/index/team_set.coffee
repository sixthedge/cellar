import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init_base: ->
    @init_team().then =>
      @init_review_sets().then => 
        @set_all_data_loaded()

  init_team: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get('team').then (team) =>
        @set 'team', team
        @set 'team_members', team.get('users')
        resolve()

  init_review_sets: ->
    params = 
      id:      @get 'assessment.id'
      team_id: @get 'model.id'
    options =
      action: 'review_sets'
      model:  ns.to_p('tbl:review_set')

    @tc.query_action(ns.to_p('tbl:assessment'), params, options).then (review_sets) =>
      @set 'review_sets', review_sets
