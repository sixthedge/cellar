class ThinkspaceTimer

  constructor: (@platform) ->
    @util  = @platform.util
    @timer = @platform.timer
    @nsio  = @platform.nsio

  on_connection: (socket) ->
    socket.on @util.client_event('timer_list'), (data) => @timer_list_event(socket, data)
    socket.on @util.client_event('timer_show'), (data) => @timer_show_event(socket, data)

  timer_list_event: (socket, data=null) ->
    user_id = @util.get_user_id(socket)
    return unless user_id
    timers = if @util.is_superuser(socket) then @timer.get_all_timers() else @timer.find_timers_by(uid: user_id)
    event  = @util.server_event('timer_list')
    value  = (timer.data for timer in timers)
    @util.debug @util.bold_line("TIMER LIST for user id '#{user_id}'.", 'magenta'), {event, timers: value.length}
    socket.emit(event, {value})

  timer_show_event: (socket, data=null) -> @timer.emit_timer_show(socket, data)

  to_string: -> 'ThinkspaceTimer'

module.exports = ThinkspaceTimer
