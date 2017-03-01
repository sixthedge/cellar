import ember  from 'ember'
import base   from 'thinkspace-base/components/base'
import m_dock from 'thinkspace-dock/mixins/main'

export default base.extend m_dock,
  tagName: ''

  gradebook: ember.inject.service()

  addon_config:
    engine:               'thinkspace-gradebook'
    display:              'Gradebook'
    icon:                 'tsi tsi-left tsi-tiny tsi-gradebook_white'
    toggle_property:      'show_addon'
    top_pocket:           true
    top_pocket_singleton: true
    group:                'middle'

  show_addon:       false
  can_access_addon: ember.computed.bool 'thinkspace.current_assignment.can.gradebook'

  ownerables:           null
  selected_ownerable:   null
  is_viewing_scorecard: true

  is_team_ownerables: false
  current_team:       null

  actions:
    select: (ownerable) ->
      return if ownerable == @get('selected_ownerable')
      @set 'selected_ownerable', ownerable
      @gradebook.change_ownerable(ownerable)

    toggle_is_viewing_scorecard: -> @toggleProperty 'is_viewing_scorecard'; return

  init_dock: ->
    @gradebook = @get('gradebook')
    @addObserver 'thinkspace.current_phase', @, 'handle_phase_change'

  handle_phase_change: ->
    ember.run.schedule 'afterRender', =>
      return unless @get('show_addon')
      return if ember.isBlank @get('thinkspace.current_phase')
      return if @gradebook.is_destroyed(@)
      @gradebook.addon_ownerable_valid().then (valid) =>
        if valid
          @gradebook.call_change_components(phase: true)
        else
          @set_ownerables().then => @gradebook.call_change_components(phase: true)

  open_addon:  ->
    new ember.RSVP.Promise (resolve, reject) =>
      @gradebook.open_addon().then =>
        @set_ownerables().then => resolve()

  close_addon: ->
    @gradebook.close_addon()
    @setProperties(ownerables: null, selected_ownerable: null, current_team: null)

  set_ownerables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @gradebook.get_ownerables().then (ownerables) =>
        @gradebook.get_selected_ownerable().then (ownerable) =>
          @set 'selected_ownerable', ownerable
          @gradebook.get_current_team().then (team) =>
            @set 'is_team_ownerables', @gradebook.is_phase_team_ownerables()
            @set 'current_team', team
            @set 'ownerables', ownerables
            resolve()

  valid_addon_ownerable: -> @gradebook.valid_addon_ownerable()
