class SocketIOTimer

  once:        require('./timer/type/once')
  countdown:   require('./timer/type/countdown')
  countup:     require('./timer/type/countup')
  helpers_mod: require('./timer/helpers')
  reload_mod:  require('./timer/reload')

  constructor: (@platform) ->
    @util    = @platform.util
    @nsio    = @platform.nsio
    @helpers = new @helpers_mod(@)
    @timers  = {}
    # @testreminders()  # TESTING ONLY
    # @testall()   # TESTING ONLY
    # @testlist()  # TESTING ONLY
    # @testsuper() # TESTING ONLY

  reload: -> new @reload_mod(@platform).process()

  process: (data) ->
    type = @helpers.data_type(data)
    switch type
      when 'cancel'     then @cancel(data)
      when 'once'       then @add(@once, data)
      when 'countdown'  then @add(@countdown, data)
      when 'countup'    then @add(@countup, data)
      else
        @util.warn "Unknown timer-type '#{type}'. data: ", data

  add: (mod, data) ->
    id          = @helpers.data_id(data)
    uid         = @helpers.data_user_id(data)
    timer       = new mod(@)
    hash        = (@timers[id] ?= {})
    cids        = (hash.cids ?= {})
    cid         = @helpers.get_child_id(cids)
    cids[cid]   = timer
    timer.id    = id
    timer.cid   = cid
    timer.uid   = uid
    timer.data  = data
    timer.title = @helpers.data_title(data)
    timer.max   = 200 # for count up/down timers
    timer.process()

  remove: (timer) ->
    timer.cancel()
    id   = timer.id
    cid  = timer.cid
    cids = @get_cids(id)
    delete(cids[cid])
    @cancel_id(id) if @helpers.get_object_keys_length(cids) == 0

  cancel: (data) ->
    @util.debug @util.bold_line('TIMER CANCEL', 'red'), data
    @cancel_id(id) for id in @helpers.data_cancel_ids(data)

  cancel_id: (id) ->
    cids = @get_cids(id)
    for cid, timer of cids
      @emit_cancel(timer)
      timer.cancel()
    delete(@timers[id])

  cancel_ids: (ids) -> @cancel(id) for id in @util.make_array(ids)

  emit_cancel: (timer) ->
    data = timer.data
    return unless @util.is_hash(data)
    rooms      = @util.data_rooms(data)
    room_event = @helpers.data_event(data)
    id         = timer.id
    emit_data  = {id, cancel: true}
    @util.debug @util.bold_line("CANCEL TIMER EMIT:\n", 'red'), {rooms, room_event, emit_data}
    @emit_to_rooms(rooms, room_event, emit_data)

  # ###
  # ### Emit to Rooms.
  # ###

  emit: (timer) ->
    data = timer.data
    return unless @util.is_hash(data)
    if timer.final
      rooms      = @util.data_rooms(data)
      room_event = @helpers.data_event(data)
      id         = timer.id
      emit_data  = {id, final: true}
      if @util.debugging
        @util.blank_line()
        @util.debug @util.bold_line("TIMER #{timer.type} final emit:\n", 'magenta'), {id, rooms, room_event, data: emit_data}
        @util.blank_line()
      @emit_to_rooms(rooms, room_event, emit_data)
      @emit_final(timer, data)
    else
      @emit_non_final(timer, data)

  emit_non_final: (timer, data) ->
    rooms        = @util.data_rooms(data)
    room_event   = @helpers.data_event(data)
    emit_data    = timer.emit or {}
    emit_data.id = timer.id unless emit_data.id
    @emit_to_rooms(rooms, room_event, emit_data)

  emit_final: (timer, data) ->
    rooms = @util.data_rooms(data)
    if @util.is_hash_present(data.value)
      room_event = @util.data_room_event(data)
      emit_data  = {value: data.value}
    else
      emit_data  = timer.emit or {}
      room_event = @helpers.data_event(data)
    if @util.debugging
      id = timer.id
      @util.debug @util.bold_line('FINAL TIMER EMIT:' + @util.sep(), 'yellow')
      @util.say timer.emit
      @util.say {id, rooms, room_event, emit_data}
      @util.say @util.color_line(@util.sep(), 'yellow')
      @util.blank_line()
    @emit_to_rooms(rooms, room_event, emit_data)
    @remove(timer)

  emit_to_rooms: (rooms, room_event, emit_data) ->
    for room in rooms
      event = @util.data_room_room_event(room, {room_event})
      @nsio.in(room).emit(event, emit_data)

  # ###
  # ### Emit to Socket.
  # ###

  # Emit the last message from the timer(s) to a single user (e.g. socket).
  # Typically this is when a timer based page is loaded or when the user refreshes
  # a page with a timer so they can view the last message without waiting for
  # next timer interval message.
  emit_timer_show: (socket, data) ->
    return unless @util.can_access(socket)
    return unless @util.is_hash(data)
    rooms = @util.data_rooms(data)
    return if @util.is_array_blank(rooms)
    room_event = @util.data_room_event(data)
    id         = data.id
    timers     = @find_timers_by({id, rooms})
    return if @util.is_array_blank(timers)
    for timer in timers
      emit_data = timer.emit or {}
      for room in rooms
        event = @util.data_room_room_event(room, {room_event})
        @util.debug @util.bold_line("TIMER SHOW for a user.", 'magenta'), ' sid: ', socket.id, {id, room, event, emit_data}
        socket.emit(event, emit_data)

  # ###
  # ### Find By.
  # ###

  find_timers_by: (options={}) ->
    ids      = options.id or options.ids
    uids     = options.uid or options.uids or options.user_id or options.user_ids
    rooms    = options.room or options.rooms
    ids      = @util.make_array(ids)   if ids
    uids     = @util.make_array(uids)  if uids
    rooms    = @util.make_array(rooms) if rooms
    timers   = []
    for timer in @get_all_timers()
      matches = [@is_timer_ids_match(timer, ids), @is_timer_uids_match(timer, uids), @is_timer_rooms_match(timer, rooms)]
      timers.push(timer) unless @util.array_contains(matches, false)
    timers

  is_timer_ids_match:   (timer, ids)   -> return true unless ids;  @util.array_contains(ids, timer.id)
  is_timer_uids_match:  (timer, uids)  -> return true unless uids; @util.array_contains(uids, timer.uid)
  is_timer_rooms_match: (timer, rooms) ->
    return true unless rooms
    timer_rooms = @util.data_rooms(timer.data)
    return false unless timer_rooms
    true in (room in timer_rooms for room in rooms)

  # ###
  # ### Helpers.
  # ###

  # WARNING: Internal use only!  Will cancel 'all' timers.
  cancel_all: -> @cancel_id(id) for id, value of @timers

  get_ids: -> @util.hash_keys(@timers)

  get_cids: (id) -> (@timers[id] or {}).cids or {}

  get_all_timers: ->
    timers = []
    for id, hash of @timers
      timers.push(timer) for cid, timer of (hash.cids or {})
    timers

  to_string: -> 'SocketIOTimer'

  # ###
  # ### TESTING ONLY
  # ###
  testreminders: ->
    test = require('./timer/test')
    data = new test()
    # @process data.test_reminders(message: 'Test message 1', inc: 7, id: 'message1')
    # @process data.test_reminders(message: 'Test message 2', id: 'message2')
    @process data.test_reminders(message: 'Test message 1', id: 'message1', inc: 60, end_at: 3000)
    @process data.test_reminders(message: 'Test message 2', id: 'message2', inc: 30, start_at: 50, end_at: 2000, user_id: 999)

  testall: ->
    test = require('./timer/test')
    data = new test()
    @process data.once1()
    @process data.countdown1()
    @process data.countdown2()
    @process data.countdown3()
    @process data.countdown4()
    @process data.countup1()
    @process data.countup2()
    @process data.countup3()

  testlist:->
    test = require('./timer/test')
    data = new test()
    @process data.list1()
    @process data.list2()

  testsuper: ->
    test = require('./timer/test')
    data = new test()
    @process data.super1()
    @process data.super2()
    @process data.super3()
    @process data.super4()
  # ###
  # ### TESTING ONLY
  # ###

module.exports = SocketIOTimer
