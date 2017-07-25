import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns from 'totem/ns'

export default base.extend

  actions:
    generate: ->
      @set_loading 'all'

      params =
        type: 'ownerable_data'
        auth: 
          authable_type: ns.to_p('assignment')
          authable_id:   @get('model.id')

      query =
        verb: 'POST'
        action: 'generate'

      @tc.query_data(ns.to_p('report:report'), params, query).then (payload) =>
        @set 'generate_success', true
        @reset_loading 'all'