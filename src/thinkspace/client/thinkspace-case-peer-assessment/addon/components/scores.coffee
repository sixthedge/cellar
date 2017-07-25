import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # scores.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base.extend

  init_base: -> 
    @set_loading 'all'
    @init_assignment().then =>
      @init_phase().then =>
        @reset_loading 'all'

  init_assignment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      params = 
        id: @get('model.id')
      options =
        action: 'load'
        model:  ns.to_p('assignment')
      @tc.query_action(ns.to_p('assignment'), params, options).then (assignment) =>
        resolve assignment

  init_phase: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model').get(ns.to_p('phases')).then (phases) =>
        phase = phases.get('firstObject')
        @set 'phase', phase
        resolve(phase)

  actions:
    generate: ->
      @set_loading 'all'

      params =
        type: 'ownerable_data'
        auth: 
          authable_type: ns.to_p('phase')
          authable_id:   @get('phase.id')

      query =
        verb: 'POST'
        action: 'generate'

      @tc.query_data(ns.to_p('report:report'), params, query).then (payload) =>
        @set 'generate_success', true
        @reset_loading 'all'