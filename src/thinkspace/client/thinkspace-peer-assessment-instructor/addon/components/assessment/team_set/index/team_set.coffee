import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Computed Properties
  is_approved:     ember.computed.equal 'model.state', 'approved'
  is_sent:         ember.computed.equal 'model.state', 'sent'

  review_sets: ember.computed.reads 'model.review_sets'

  incomplete_review_sets: ember.computed 'model.review_sets.@each.status', -> @get('progress_report').get_incomplete_review_sets_for_team_set(@get('model'))

  # ### Helpers
  state_change: (state) ->

    model           = @get 'model'
    progress_report = @get 'progress_report'

    query = 
      id:     model.id
    options =
      action: state
      verb:   'PUT'
      single: true

    @tc.query_action(ns.to_p('tbl:team_set'), query, options).then (team_set) =>
      team_set.get(ns.to_p('tbl:review_sets')).then (review_sets) =>
        progress_report.process_team_sets(team_set)
        progress_report.process_review_sets(team_set, review_sets)

  # ### Actions
  actions:
    toggle_approve: -> if @get('is_approved') then @state_change('unapprove') else @state_change('approve')
    select:         -> @sendAction 'select', @get('model')
    select_review_set: (review_set) -> @sendAction 'select', @get('model'), review_set