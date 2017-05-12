import ember from 'ember'

export default ember.Object.extend

  validate:       'validate'
  width_selector: null
  show_select:    true

  message:      null
  base_message: null
  teams:        null
  users:        null
  due_at:       null
  state:        null
  timer:        null

  timer_type:      'countdown'
  timer_unit:      'minute'

  team_users:       null
  show_all:         false

  init: ->
    @_super()
    @time_at = new Date()
    @errors  = []

  error_message: 'There are errors.  Please correct before doing the transition.'

  clear_errors: -> @get('errors').clear()
  error: (e)    -> @get('errors').pushObject(e)

  clear_message:     -> @set_message(null)
  get_message:       -> @get 'message'
  set_message: (msg) -> @set 'message', msg

  get_base_message:       -> @get 'base_message'
  set_base_message: (msg) -> @set 'base_message', msg

  get_team_users:              -> @get 'team_users'
  set_team_users: (team_users) -> @set 'team_users', team_users

  get_all_users: ->
    team_users = @get_team_users() or []
    users      = []
    for tu in team_users
      for user in tu.users
        u      = ember.merge({}, user)
        u.team = ember.merge({}, tu.team or {})
        users.push(u)
    users

  get_teams:         -> @get 'teams'
  set_teams: (teams) -> @set 'teams', teams

  get_users:         -> @get 'users'
  set_users: (users) -> @set 'users', users

  get_timer:        -> @get 'timer'
  set_timer: (opts) -> @set 'timer', opts

  get_phase_state:         -> @get 'phase_state'
  set_phase_state: (state) -> @set 'phase_state', state

  select_all_teams_on: -> @set 'all_teams', true
  select_all_users_on: -> @set 'all_users', true
  select_all_teams:    -> @get('all_teams') == true
  select_all_users:    -> @get('all_users') == true

  get_show_all: -> @get 'show_all'
  show_all_on:  -> @set 'show_all', true

  get_data: -> 
    users          = @get_users()
    teams          = @get_teams()
    user_ids       = if ember.isBlank(users) then null else users.mapBy('id')
    team_ids       = if ember.isBlank(teams) then null else teams.mapBy('id')
    message        = @get_message()
    release_at     = @get 'release_at'
    due_at         = @get 'due_at'
    transition_now = @get 'transition_now'
    phase_state    = @get_phase_state()
    timer          = @get_timer() or {}
    settings       = timer.settings
    start_at       = timer.start_at
    end_at         = timer.end_at
    # Set data values.
    data                = {}
    data.user_ids       = user_ids        if ember.isPresent(user_ids)
    data.team_ids       = team_ids        if ember.isPresent(team_ids)
    data.message        = message         if ember.isPresent(message)
    data.release_at     = release_at      if ember.isPresent(release_at)
    data.due_at         = due_at          if ember.isPresent(due_at)
    data.transition_now = transition_now  if ember.isPresent(transition_now)
    data.phase_state    = phase_state     if ember.isPresent(phase_state)
    data.timer_settings = settings        if ember.isPresent(settings)
    data.timer_start_at = start_at        if ember.isPresent(start_at)
    data.timer_end_at   = end_at          if ember.isPresent(end_at)
    data

  # ###
  # ### Messages.
  # ###

  timer_message_change: ember.observer 'due_at', -> @add_default_message() if @has_default_message()

  get_timer_message: ->
    msg = @get_base_message()
    return msg if ember.isPresent(msg)
    @get_default_message()
    @get_base_message()

  default_message: -> "Your #{@name} is due at"

  default_message_regex: ->
    message = @default_message()
    new RegExp("#{message}.*?\\\.", 'i')

  has_default_message: ->
    message = @get_message()
    return false if ember.isBlank(message)
    regex = @default_message_regex()
    ember.isPresent(message.match(regex))

  get_default_message: ->
    @set_base_message(null)
    due_at = @get('due_at')
    return null if ember.isBlank(due_at)
    hhmm = @am.date_to_hh_mm(due_at)
    mins = @am.minutes_from_now(due_at)
    inmm = @am.minutes_from_now_message(mins)
    dmsg = @default_message() + " #{hhmm}"
    @set_base_message(dmsg)
    dmsg += if mins <= 0 then ' (now).' else " (in about #{inmm})."
    dmsg

  add_default_message: ->
    dmsg = @get_default_message()
    return if ember.isBlank(dmsg)
    message = @get_message()
    if ember.isPresent(message)
      if @has_default_message()
        regex = @default_message_regex()
        msg   = message.replace(regex, dmsg)
      else
        msg = message + '  ' + dmsg
    else
      msg = dmsg
    @set_message(msg)

  toString: -> (@name or '') + 'ReadinessAssuranceData'
