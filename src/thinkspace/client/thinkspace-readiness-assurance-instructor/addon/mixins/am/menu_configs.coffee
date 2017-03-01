import ember from 'ember'

export default ember.Mixin.create

  # ###
  # ### Menu Component Paths.
  # ###

  c_menu_irat:         'irat/menu'
  c_menu_irat_to_trat: 'irat/menu_to_trat'
  c_menu_trat:         'trat/menu'
  c_menu_trat_summary: 'trat/menu_summary'
  c_menu_clear:        'shared/menu/clear'

  c_messages_send: 'messages/send'
  c_messages_view: 'messages/view'

  c_timers:  'timers/timers'
  c_tracker: 'tracker/tracker'

  c_irat_phase_states:   'irat/phase_states'
  c_irat_to_trat_after:  'irat/to_trat_after'
  c_irat_to_trat_due_at: 'irat/to_trat_due_at'
  c_irat_to_trat_now:    'irat/to_trat_now'

  c_trat_phase_states:    'trat/phase_states'
  c_trat_summary_answers: 'trat/summary/answers'
  c_trat_summary_teams:   'trat/summary/teams'
  c_trat_teams:           'trat/teams/teams'

  # ###
  # ### Menu Configs.
  # ###

  dashboard_menu: ember.computed ->
    [
      {component: @c_menu_clear,    title: 'Clear', is_clear: true}
      {component: @c_menu_irat,     title: 'IRAT', clear: true}
      {component: @c_menu_trat,     title: 'TRAT', clear: true}
      {component: @c_tracker,       title: 'Track Users', clear: true}
      {component: @c_timers,        title: 'Timers', top: true}
      {component: @c_messages_send, title: 'Send Message', top: true}
      {component: @c_messages_view, title: 'View Messages', top: true, first: true}
    ]

  irat_menu: ember.computed ->
    [
      {component: @c_menu_irat_to_trat, title: 'Transition Teams to TRAT', clear: true}
      {component: @c_irat_phase_states, title: 'Phase States', clear: true}
    ]

  irat_to_trat_menu: ember.computed ->
    [
      {component: @c_irat_to_trat_after,  title: 'After', default: true, clear: true}
      {component: @c_irat_to_trat_due_at, title: 'Due At', clear: true}
      {component: @c_irat_to_trat_now,    title: 'Now', clear: true}
    ]

  trat_menu: ember.computed ->
    [
      {component: @c_menu_clear,         title: 'Clear', is_clear: true}
      {component: @c_trat_teams,         title: 'Teams'}
      {component: @c_menu_trat_summary,  title: 'Summary'}
      {component: @c_trat_phase_states,  title: 'Phase States'}
    ]

  trat_summary_menu: ember.computed ->
    [
      {component: @c_trat_summary_answers,  title: 'By Answer Counts', default: true}
      {component: @c_trat_summary_teams,    title: 'By Teams'}
    ]

  # Return the 'select' menu component property for (team_users | teams | users) defined in config.select (default team_users).
  select_component: (config) ->
    val  = config.select or 'team_users'
    @["c_admin_shared_#{val}_select"]
