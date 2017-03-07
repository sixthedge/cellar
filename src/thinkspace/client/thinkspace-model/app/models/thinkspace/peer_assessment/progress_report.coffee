import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(),
  
  # ### Attributes
  assessment_id: ta.attr('string_id')
  value:         ta.attr()

  # ### Computed Properties
  team_sets:          ember.computed.reads 'value.team_sets'
  approved_team_sets: ember.computed 'team_sets.@each.state', -> @get('team_sets').filter (team_set) -> team_set.state == 'approved'
  neutral_team_sets:  ember.computed 'team_sets.@each.state', -> @get('team_sets').filter (team_set) -> team_set.state  == 'neutral'

  students_complete: ember.computed.reads 'value.complete.review_sets'
  teams_complete:    ember.computed.reads 'value.complete.team_sets'

  students_total: ember.computed.reads 'value.total.review_sets'
  teams_total:    ember.computed.reads 'value.total.team_sets'

  all_teams_approved: ember.computed 'team_sets.@each.state', -> @get('team_sets').every (team_set) -> team_set.state == 'approved'

  # ### Methods
  process_team_sets: (records) -> 
    records = ember.makeArray(records) unless ember.isArray(records)
    records.forEach (record) =>
      team_set = @get('team_sets').findBy 'id', parseInt(record.get('id'))
      ember.set team_set, 'state', record.get('state')

  process_review_sets: (team_set, review_sets) ->
    review_sets = ember.makeArray(review_sets) unless ember.isArray(review_sets)
    team_set_data = @get('team_sets').findBy 'id', parseInt(team_set.get('id'))
    review_sets.forEach (review_set) =>
      review_set_data = team_set_data.review_sets.findBy 'ownerable_id', parseInt(review_set.get('ownerable_id'))
      ember.set review_set_data, 'id', review_set.get('id')
      ember.set review_set_data, 'state', review_set.get('state')
      ember.set review_set_data, 'status', review_set.get('status')

  get_incomplete_review_sets_for_team_set: (team_set) -> team_set.review_sets.filter (review_set) -> review_set.status != 'complete'

