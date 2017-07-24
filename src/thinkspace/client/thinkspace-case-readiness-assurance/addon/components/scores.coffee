import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns from 'totem/ns'

export default base.extend

  actions:
    generate: ->
      params =
        type: 'ownerable_data'
        auth: 
          authable_type: ns.to_p('assignment')
          authable_id:   @get('model.id')

      query =
        verb: 'POST'
        action: 'generate'

      @tc.query_action(ns.to_p('report:report'), params, query).then (payload) =>
        console.log "report generated!"