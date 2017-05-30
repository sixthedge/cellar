import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  afterModel: (model, transition) ->
    console.log "calling after model"
    @transitionTo('teams.manage', model) if transition.targetName == ns.to_r('team_builder', 'teams.index')
      
