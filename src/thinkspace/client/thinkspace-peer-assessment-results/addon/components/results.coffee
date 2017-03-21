import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

###
# # results.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-results**
###
export default base_component.extend
  # ## Properties
  # ### Internal Properties
  calculated_overview: null # Anonymized result from the server.
  assessment:          null

  # ### Component paths
  c_overview_type: ns.to_p 'tbl:overview', 'type', 'base'

  # ## Events
  init_base: ->
    @init_assessment().then =>
      @init_overview().then =>
        @set_all_data_loaded()

  # ## Helpers
  init_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get('assignment')

      query =
        assignment_id: assignment.get('id')
      options =
        action: 'fetch'
        model:  ns.to_p('tbl:assessment')

      @tc.query_action(ns.to_p('assessment'), query, options).then (assessment) =>
        @set 'assessment', assessment.get('firstObject')
        resolve()
      , (error) => reject error

  init_overview: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment      = @get 'assessment'
      assessment.get('authable').then (authable) =>
        query           = @totem_scope.get_view_query(assessment, sub_action: 'overview')
        @totem_scope.add_authable_to_query(query)
        query.data.id = assessment.get('id')
        query         = query.data
        options       = 
          action: 'view'
          verb:   'GET'

        @tc.query_data(ns.to_p('assessment'), query, options).then (payload) =>
          @set 'calculated_overview', payload
          resolve()
        , (error) => 
          @transition_to_cases_show()
          resolve()

  transition_to_cases_show: ->
    assignment = @get('assignment')
    @get_app_route().transitionTo 'cases.show', assignment