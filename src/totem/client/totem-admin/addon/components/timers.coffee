import ember from 'ember'
import util  from 'totem/util'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,

  pubsub: ember.inject.service()
  admin:  ember.inject.service()

  timer_data: null
  ready:      false

  sorted_timers: ember.computed.sort 'timer_data', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      id:        {id: 'id', sort: 'id', text: 'Timer Id'}
      room:      {id: 'room', sort: 'sort_room', text: 'Room'}
      start_at:  {id: 'start_at', sort: 'start_date', text: 'Start At'}
      end_at:    {id: 'end_at', sort: 'end_date', text: 'End At'}
      remaining: {id: 'remaining', sort: 'remaining', text: 'Remaining'}
      title:     {id: 'title', sort: 'sort_title', text: 'Title'}
      type:      {id: 'type', sort: 'sort_type', text: 'Type'}
      message:   {id: 'message', sort: 'sort_message', text: 'Message'}
      interval:  {id: 'interval', sort: 'interval', text: 'Interval'}
      user_id:   {id: 'user_id', sort: 'user_id', text: 'User Id'}

  actions:
    refresh: -> @emit_timer_list()

  init: ->
    @_super(arguments...)
    @pubsub     = @get('pubsub')
    @am         = @get('admin')
    @ttz        = @get('ttz')
    @event      = 'timer_list'
    @timer_date = null
    @get_timer_list()

  didInsertElement: -> @get('admin').set_other_header_links_inactvie('timers')

  get_timer_list: ->
    @socket = @pubsub.get_socket()
    sevent = @pubsub.server_event(@event)
    @pubsub.on(@socket, sevent, @, 'handle_timer_list')
    @emit_timer_list()

  emit_timer_list: ->
    cevent = @pubsub.client_event(@event)
    @socket.emit(cevent)

  handle_timer_list: (data) ->
    console.info 'handle_timer_list:', data
    @set_timers(data)

  set_timers: (data) ->
    new ember.RSVP.Promise (resolve, reject) =>
      values   = data.value or []
      values   = values.sortBy 'timer.settings.end_at'
      promises = (@format_timer_value(value) for value in values)
      ember.RSVP.all(promises).then (timers) =>
        @set 'timer_data', timers
        @set 'ready', true
        @notifyPropertyChange 'sorted_timers'
        resolve()

  format_timer_value: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      settings = value.timer or {}
      timer    =
        id:            settings.id
        title:         settings.title or 'no-title'
        type:          settings.type
        interval:      settings.interval
        unit:          settings.unit
        message:       settings.message
        room_event:    settings.room_event
        user_id:       settings.user_id
      @add_show_interval(timer)
      @add_room_and_users(timer, value)
      @add_end_at(timer, settings)
      @add_start_at(timer, settings)
      @make_timer_sortable(timer)
      resolve(timer)

  add_show_interval: (timer) ->
    interval = timer.interval
    if ember.isBlank(interval)
      timer.interval      = 0
      timer.show_interval = 'no reminders'
    else
      unit = @am.pluralize(interval, timer.unit)
      timer.show_interval = "#{timer.interval} (#{unit})"

  add_room_and_users: (timer, value) ->
    rooms = ember.makeArray(value.rooms).compact()
    users = []
    platform = @am.get_platform()
    regex = new RegExp("#{platform}.*?\\\d+")
    timer_room = null
    for room in rooms
      match = room.match(regex)
      if ember.isPresent(match)
        timer_room = match[0] unless timer_room
        users.push room.replace(timer_room,'').replace(/^\//,'')
    timer.room  = timer_room
    timer.users = users.sort()

  add_end_at: (timer, settings) ->
    date = settings.end_at
    return if ember.isBlank(date)
    timer.end_date    = new Date(date)
    timer.show_end_at = @am.format_time(timer.end_date)
    timer.remaining   = @am.seconds_from_now(timer.end_date)
    min_now           = if timer.remaining > 0 then Math.floor(timer.remaining / 60) else 0
    timer.from_now    = "#{timer.remaining} seconds (#{min_now} mins)"

  add_start_at: (timer, settings) ->
    date = settings.start_at
    return if ember.isBlank(date)
    timer.start_date    = new Date(date)
    timer.show_start_at = @am.format_time(timer.start_date)

  make_timer_sortable: (timer) ->
    timer.sort_room    = (timer.room or '').toLowerCase()
    timer.sort_title   = (timer.title or '').toLowerCase()
    timer.sort_type    = (timer.type or '').toLowerCase()
    timer.sort_message = (timer.message or '').toLowerCase()
