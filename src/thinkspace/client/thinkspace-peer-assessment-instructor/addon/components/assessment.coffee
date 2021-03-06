import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Properties
  # ### Internal Properties
  selected_team_set: null

  # ## Events
  init: ->
    @_super()
    @init_assessment().then => @init_teams().then => @init_team_sets().then => @init_progress_report().then => @set_all_data_loaded()
        
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
        assessment = assessment.get('firstObject')
        @set 'model', assessment
        resolve()

  init_teams: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_assessment_query()
      options = @get_assessment_query_options('teams', ns.to_p('team'))

      @tc.query_action(ns.to_p('tbl:assessment'), query, options).then (teams) =>
        @set 'teams', teams
        resolve()

  init_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      id = @get 'model.id'
      params = 
        id: id
      options =
        action: 'team_sets'
        model:  ns.to_p('tbl:team_set')

      @tc.query_data(ns.to_p('tbl:assessment'), params, options).then (team_sets) =>
        @set 'team_sets', team_sets
        resolve()

  init_progress_report: ->
    new ember.RSVP.Promise (resolve, reject) =>
      id = @get 'model.id'
      params = 
        id: id
      options =
        action: 'progress_report'

      @tc.query_data(ns.to_p('tbl:assessment'), params, options).then (data) =>
        progress_report = @get_store().createRecord ns.to_p('progress_report'), 
          assessment_id: id
          value:         data
        @set 'progress_report', progress_report
        resolve()

  get_assessment_query: ->
    query =
      id: @get('model.id')

  get_assessment_query_options: (action, model) ->
    options =
      action: action
      model:  model

  set_selected_team_set: (team_set) -> @set 'selected_team_set', team_set
  set_selected_review_set: (review_set) -> @set 'selected_review_set', review_set

  get_approve_modal:   -> $('.ts-tblpa_modal')
  show_approve_modal:  -> @get_approve_modal().foundation('reveal', 'open')
  close_approve_modal: -> @get_approve_modal().foundation('reveal', 'close')

  # ## Actions
  actions:
    show_approve_modal:  -> @show_approve_modal()
    close_approve_modal: -> @close_approve_modal()

    approve: ->
      assessment = @get 'model'
      query      = 
        id:     assessment.get 'id'
        action: 'approve'
        verb:   'PUT'
      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('tbl:assessment'), query, single: true).then =>
        @totem_messages.hide_loading_outlet()
        @close_approve_modal()
        @set 'has_sent', true

    select_team_set: (team_set, review_set) -> 
      @set_selected_team_set team_set
      @set_selected_review_set review_set
