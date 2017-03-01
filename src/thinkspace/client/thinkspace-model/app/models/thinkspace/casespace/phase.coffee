import ember          from 'ember'
import ta             from 'totem/ds/associations'
import tc             from 'totem/cache'
import resource_mixin from 'thinkspace-resource/mixins/resources'

export default ta.Model.extend resource_mixin, ta.totem_data, ta.add(
    ta.belongs_to 'assignment',        reads: {}
    ta.belongs_to 'configuration',     reads: {}
    ta.belongs_to 'phase_template',    reads: {}
    ta.has_many   'phase_components',  reads: {}
    ta.has_many   'phase_states',      reads: {filter: true, notify: true}
  ),

  title:             ta.attr('string')
  phase_template_id: ta.attr('number')
  team_category_id:  ta.attr('number')
  team_set_id:       ta.attr('number')
  active:            ta.attr('boolean')
  team_ownerable:    ta.attr('boolean')
  position:          ta.attr('number')
  description:       ta.attr('string')
  user_action:       ta.attr('string')
  default_state:     ta.attr('string')
  state:             ta.attr('string')
  settings:          ta.attr()

  totem_data_config: ability: true

  is_team_ownerable: -> @get('team_ownerable')

  is_team_collaboration: ember.computed.equal 'team_category_id', 2 # Team Collaboration is 2

  # Phase Configuration.
  configuration_validate: ember.computed.reads 'settings.validation.validate'
  max_score:              ember.computed.reads 'settings.phase_score_validation.numericality.less_than_or_equal_to'
  submit_text:            ember.computed.reads 'settings.submit.text'
  show_errors_on_submit:  ember.computed.reads 'settings.submit.show_errors'
  submit_visible:         ember.computed.reads 'settings.submit.visible'
  is_submit_visible:      ember.computed.bool  'submit_visible'

  has_auto_score:                     ember.computed.reads 'settings.actions.submit.auto_score'
  has_unlock_phase:                   ember.computed.equal 'settings.actions.submit.unlock', 'next'
  has_complete_phase:                 ember.computed.equal 'settings.actions.submit.state', 'complete'
  has_team_category:                  ember.computed.notEmpty 'team_category_id'
  has_team_set:                       ember.computed.notEmpty 'team_set_id'
  has_team_category_without_team_set: ember.computed 'has_team_category', 'has_team_set', -> @get('has_team_category') and !@get('has_team_set')

  # Phase states.
  phase_state:     ember.computed.reads 'phase_states.firstObject'
  current_state:   ember.computed.or    'phase_state.current_state', 'default_state'
  is_unlocked:     ember.computed.bool  'phase_state.is_unlocked'
  is_locked:       ember.computed.bool  'phase_state.is_locked'
  is_active:       ember.computed.equal 'state', 'active'
  is_inactive:     ember.computed.equal 'state', 'inactive'
  is_archived:     ember.computed.equal 'state', 'archived'
  is_not_active:   ember.computed.not   'is_active'
  is_not_archived: ember.computed.not   'is_archived'

  # Previous/Next Phases.
  previous_phase: ember.computed ta.to_p('assignment'), ta.to_prop('assignment', 'phases', 'length'), -> @get_phase_at_index_increment(-1)
  next_phase:     ember.computed ta.to_p('assignment'), ta.to_prop('assignment', 'phases', 'length'), -> @get_phase_at_index_increment(+1)

  get_phase_at_index_increment: (increment) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p 'assignment').then (assignment) =>
        assignment.get('active_phases').then (phases) =>
          index     = phases.indexOf(@)
          new_index = index + increment
          phase     = phases.objectAt(new_index)
          return resolve(null) unless ember.isPresent(phase)
          resolve phase
        , (error) => reject(error)
      , (error) => reject(error)
    ta.PromiseObject.create promise: promise

  # Should friendly here be 'defaulted' or something as a convention?
  # => Friendly would usually mean something like '2014-09-01 12:01:00Z' to 'Aug. 1st 2014'
  friendly_submit_visible: ember.computed 'submit_visible', -> ( @get('submit_visible')? and @get('submit_visible') ) or true
  friendly_submit_text:    ember.computed 'submit_text',    -> @get('submit_text') or 'Submit'
  friendly_max_score:      ember.computed 'max_score',      -> (@get('max_score')? and parseInt(@get('max_score'))) or 1

  # ### Movement helpers
  # => Note, these do not save the movement positions, only set them client side.
  move_to_top: ->
    @get_sorted_phases().then (phases) =>
      phases.removeObject(@)
      phases.insertAt 0, @
      phases.forEach (phase, index) => phase.set 'position', index

  move_to_bottom: ->
    @get_sorted_phases().then (phases) =>
      phases.removeObject(@)
      length = phases.get('length')
      phases.insertAt length, @
      phases.forEach (phase, index) => phase.set 'position', index

  move_to_offset: (offset) ->
    @get_sorted_phases().then (phases) =>
        index     = phases.indexOf(@)
        new_index = index + offset
        length    = phases.get('length')
        return if new_index >= length or new_index < 0
        phases.removeObject @
        phases.insertAt new_index, @
        phases.forEach (phase, index) => phase.set 'position', index

  get_sorted_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p('assignment')).then (assignment) =>
        if @get('is_active') then property = 'active_phases' else property = 'archived_phases'
        assignment.get(property).then (phases) =>
          sorted    = phases.sortBy('position')
          resolve(sorted)

  # ### Position helpers
  # => If the `position` gets off, the UI will still represent it correctly.
  position_in_assignment: ember.computed 'position', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      if @get('is_archived')
        resolve {value: @get('position')}
      else
        @get(ta.to_p('assignment')).then (assignment) =>
          assignment.get('active_phases').then (phases) =>
            position = phases.indexOf(@)
            return resolve({value: 0}) unless ember.isPresent(position)
            resolve {value: position + 1} # Add one since it's a count not an index.
    ta.PromiseObject.create promise: promise

  # ### State helpers
  state_change: (action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tc.query(ta.to_p('phase'), {id: @get('id'), action: action, verb: 'PUT'}, single: true).then (phase) =>
        resolve(phase)
      , (error) => @error(error)
    , (error) => @error(error)

  inactivate: -> @state_change('inactivate')
  archive:    -> @state_change('archive')
  activate:   -> @state_change('activate')
