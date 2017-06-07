import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # index.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Events
  init_base: -> @set_all_data_loaded()

  # ## Actions
  actions:
    select_team_set: (team_set, review_set) -> @sendAction 'select_team_set', team_set, review_set

    send: ->
      assessment      = @get 'assessment'
      progress_report = @get('progress_report')

      query =
        id: assessment.get 'id'
      options =
        action: 'approve'
        verb:   'PUT'
        model:  ns.to_p('tbl:team_set')
      @totem_messages.show_loading_outlet()
      @tc.query_action(ns.to_p('tbl:assessment'), query, options).then (team_sets) =>
        @totem_messages.api_success source: @, model: assessment, action: 'approve', i18n_path: ns.to_o('tbl:assessment', 'approve')
        progress_report.process_team_sets(team_sets)
        @totem_messages.hide_loading_outlet()
      , (error) =>
          @totem_messages.api_failure error, source: @, model: assessment

    approve: ->
      assessment      = @get 'assessment'
      progress_report = @get 'progress_report'

      query   = 
        id:     assessment.get('id')
      options =
        action: 'approve_team_sets'
        verb:   'PUT'
        model:  ns.to_p('tbl:team_set')

      @tc.query_action(ns.to_p('tbl:assessment'), query, options).then (team_sets) =>
        @totem_messages.api_success source: @, model: assessment, action: 'approve_team_sets', i18n_path: ns.to_o('tbl:assessment', 'approve_team_sets')
        progress_report.process_team_sets(team_sets)
      , (error) =>
          @totem_messages.api_failure error, source: @, model: assessment
