import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'phase', reads: {}
    ta.belongs_to 'phase_score', reads: {}
    ta.polymorphic 'ownerable'
  ),

  current_state:  ta.attr('string')
  title:          ta.attr('string')
  phase_id:       ta.attr('number')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')
  new_state:      ta.attr('string')  # used to update the state in the gradebook

  score:            ember.computed.reads 'phase_score.score'
  title_with_phase: ember.computed 'title', 'phase', -> "#{@get('phase.title')} - #{@get('title')}"

  computed_current_state: ember.computed.or       'current_state', 'phase.default_state'
  is_unlocked:            ember.computed          'computed_current_state', ->  ['neutral', 'unlocked'].includes(@get 'current_state')
  is_locked:              ember.computed.equal    'computed_current_state', 'locked'
  is_completed:           ember.computed.equal    'computed_current_state', 'completed'
  is_view_only:           ember.computed.or       'is_locked', 'is_completed'

  lock:              -> @set 'current_state', 'locked'
  unlock:            -> @set 'current_state', 'unlocked'
  complete:          -> @set 'current_state', 'completed'
  is_team_ownerable: -> @totem_scope.standard_record_path(@get('ownerable_type')) == ta.to_p('team')
