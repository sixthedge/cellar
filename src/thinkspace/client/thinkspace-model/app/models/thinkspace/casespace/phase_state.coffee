import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.totem_data, ta.add(
    ta.belongs_to 'phase', reads: {}
    ta.belongs_to 'phase_score', reads: {}
    ta.polymorphic 'ownerable'
  ),

  # # Attributes
  current_state:  ta.attr('string')
  title:          ta.attr('string')
  phase_id:       ta.attr('number')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')
  new_state:      ta.attr('string')  # used to update the state in the gradebook

  # # Services
  ttz: ember.inject.service()

  # # Properties
  totem_data_config: metadata: true

  # # Computed properties
  score:            ember.computed.reads 'phase_score.score'
  due_at:           ember.computed.reads 'metadata.due_at'
  unlock_at:        ember.computed.reads 'metadata.unlock_at'
  release_at:       ember.computed.reads 'metadata.release_at'
  title_with_phase: ember.computed 'title', 'phase', -> "#{@get('phase.title')} - #{@get('title')}"

  computed_current_state: ember.computed.or       'current_state', 'phase.default_state'
  is_unlocked:            ember.computed          'computed_current_state', ->  ['neutral', 'unlocked'].includes(@get 'current_state')
  is_locked:              ember.computed.equal    'computed_current_state', 'locked'
  is_completed:           ember.computed.equal    'computed_current_state', 'completed'
  is_read_only:           ember.computed.or       'is_completed', 'is_past_due'
  is_view_only:           ember.computed.or       'is_locked', 'is_completed', 'is_past_due'
  is_past_due:            ember.computed 'due_at', ->
    due_at       = @get('due_at')
    is_completed = @get('is_completed')
    return false if is_completed
    return false unless due_at
    new Date(due_at).getTime() < new Date().getTime()

  # ## Friendly times
  friendly_due_at:     ember.computed 'metadata.due_at',     -> 
    console.log "DUE AT: ", @get('due_at')
    @format_time('due_at')
  friendly_unlock_at:  ember.computed 'metadata.unlock_at',  -> @format_time('unlock_at')
  friendly_release_at: ember.computed 'metadata.release_at', -> @format_time('release_at')

  # # Helpers
  lock:              -> @set 'current_state', 'locked'
  unlock:            -> @set 'current_state', 'unlocked'
  complete:          -> @set 'current_state', 'completed'
  is_team_ownerable: -> @totem_scope.standard_record_path(@get('ownerable_type')) == ta.to_p('team')

  format_time: (property) -> 
    time = @get(property)
    return null unless time
    @get('ttz').format(time, format: 'MMM Do, h:mm a')