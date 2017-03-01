import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  server_events: ember.inject.service()

  init_base: ->
    @messages    = []
    @se          = @get('server_events')
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
    console.info 'handle_timer:', data
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
    msg.id      = data.id
    msg.message = data.message
    msg.prefix  = if data.n == (data.of-1) then 'in less than' else 'in about'
    msg.units   = data.units
    msg.label   = data.label
    msg
