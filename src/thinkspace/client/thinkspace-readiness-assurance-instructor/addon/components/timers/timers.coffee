import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import totem_timer from 'totem/timer'

export default base.extend

  timers: null

  init_base: ->
    return unless @am.pubsub_active
    @set_ready_on()

  willInsertElement: -> @get_timer_list()

  add_refresh_timer: -> @refresh_timer = totem_timer.start(source: @, method: 'get_timer_list', interval: 15000)

  get_timer_list: ->
    return unless @am.pubsub_active
    socket = @pubsub.get_socket()
    cevent = @pubsub.client_event('timer_list')
    sevent = @pubsub.server_event('timer_list')
    @pubsub.on(socket, sevent, @, 'handle_timer_list')
    socket.emit(cevent)

  handle_timer_list: (data) ->
    console.info 'handle_timer_list:', data
    @set_timers(data).then =>
      @add_refresh_timer()

  set_timers: (data) ->
    new ember.RSVP.Promise (resolve, reject) =>
      values   = data.value or []
      values   = values.sortBy 'timer.settings.end_at'
      promises = (@format_timer_value(value) for value in values)
      ember.RSVP.all(promises).then (timers) =>
        @set 'timers', timers
        @set_ready_on()
        resolve()

  format_timer_value: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      settings = value.timer or {}
      rooms    = value.rooms
      id       = settings.id
      title    = settings.title or 'no-title'
      type     = settings.type
      interval = settings.interval
      unit     = settings.unit
      end_date = new Date(settings.end_at)
      end_at   = @am.format_time(end_date)
      from_now = @am.minutes_from_now(end_date)
      if from_now > 0
        from_units = @am.pluralize(from_now, unit)
        from_now   = "#{from_now} #{from_units}"
        from_class = ''
      else
        from_class = 'ts-ra_admin-timer-about-to-fire'
        from_now   = "under 1 #{unit}"
      resolve {settings, rooms, title, end_at, type, from_now, from_class}

  actions:
    cancel: (timer) ->
      console.warn 'cancel:', timer
      timer.settings.rooms = timer.rooms
      @am.send_timer_cancel(timer: timer.settings).then =>
        @get_timer_list()
