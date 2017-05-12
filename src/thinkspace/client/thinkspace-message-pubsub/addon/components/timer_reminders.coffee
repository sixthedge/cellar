import ember from 'ember'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  server_events: ember.inject.service()

  actions:
    refresh: -> @se.timer_show({room}) for room in @timer_rooms

  init_base: ->
    @messages    = []
    @se          = @get('server_events')
    @ttz         = @get('ttz')
    @timer_rooms = @se.get_filter_rooms()
    @join_timer_rooms()

  join_timer_rooms: ->
    for room in @timer_rooms
      options =
        room:                     room
        room_event:               'timer'
        source:                   @
        callback:                 'handle_timer'
        after_authorize_callback: 'start_timer_callback'
      @se.pubsub.join(options)

  start_timer_callback: (options) -> @se.timer_show(options)

  handle_timer: (data={}) ->
    console.info 'handle_timer--->', data
    @set_message(data)

  set_message: (data) ->
    message = @get_message(data)
    id      = message.id
    return if ember.isBlank(id)
    id_message = @messages.findBy 'id', id
    if data.cancel == true or data.final == true
      @messages.removeObject(id_message) if ember.isPresent(id_message)
    else
      if ember.isBlank(id_message)
        message = ember.Object.create(message)
        @messages.pushObject(message)
      else
        id_message.setProperties(message)

  get_message: (data) ->
    msg         = {}
    emit_at     = data.emit_at
    end_at      = data.end_at
    return msg unless (emit_at and end_at)
    message      = data.message or ''
    message     += " in "
    message     += @format_duration(data, emit_at, end_at)
    message     += '.' unless util.ends_with(message, '.')
    msg.id       = data.id
    msg.message  = message
    msg

  format_duration: (data, emit_at, end_at) ->
    msg      = ''
    dd       = new Date(end_at) - new Date(emit_at)
    dd       = 0 if dd <= 0
    dd_secs  = Math.ceil(dd / 1000)
    iso      = "PT#{dd_secs}S"
    duration = moment.duration(iso)
    mins     = duration.minutes() + (duration.hours() * 60)
    secs     = duration.seconds()
    [mins, secs] = @adjust_time(data, mins, secs)
    if mins > 0
      min_text  = util.pluralize('minute', mins)
      msg      += "#{mins} #{min_text}"
    if secs > 0
      sec_text  = util.pluralize('second', secs)
      msg      += " and " if mins > 0
      msg      += "#{secs} #{sec_text}"
    msg

  # Make some minor adjustments e.g. add 1 min if secs = 59
  adjust_time: (data, mins, secs) ->
    if secs >= 59
      mins += 1
      secs  = 0
    if secs == 29
        secs = 30
    [mins, secs]
