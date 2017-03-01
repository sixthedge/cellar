import ember from 'ember'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  add: (data={}, type=null) ->
    type   ?= @message_model_type
    message = @get_message_properties(data)
    if ember.isPresent(type)
      msg = totem_scope.get_store().createRecord(type, message)
      @save_message(msg) if msg.save_message
    else
      message.tms = @
      msg         = @message_item.create(message)
      @message_queue.unshiftObject(msg)
    msg

  save_message: (msg) ->
    if msg.save_message == true
      msg.save()
    else
      if @is_function(msg.save_message)
        msg.save_message()

  # ###
  # ### Add - Message Properties.
  # ###

  get_message_properties: (data) ->
    return {} if ember.isBlank(data)
    msg = {}
    @add_message_state    data.state, msg
    @add_message_time     data.time, msg
    @add_message_to       data.to, msg
    @add_message_from     data.from, msg
    @add_message_body     data.message, msg
    @add_message_source   data.source, msg
    @add_rooms            (data.room or data.rooms), msg
    msg

  add_message_state: (state, msg)     -> msg.state   = if ember.isBlank(state) then 'new' else state
  add_message_body: (body, msg)       -> msg.body    = body
  add_message_source: (source, msg)   -> msg.source  = if ember.isBlank(source)  then null else (source.toString and source.toString())

  add_message_time: (time, msg) ->
    msg.date = time or new Date().toISOString()
    msg.time = @format_date_time(msg.date, 'MMM Do, h:mm a')

  add_rooms: (room, msg) ->
    unless ( @is_string(room) or ember.isArray(room) )
      msg.rooms = null
      return
    rooms     = ember.makeArray(room)
    msg.rooms = rooms.map (r) -> if r.match(/^server:/) then r.replace(/^server:/, '') else r

  add_message_from: (from, msg) ->
    if @is_string(from)
      msg.from = from
      return
    values   = ember.makeArray(from).compact()
    users    = msg.from_users = @extract_message_type(values, 'user')
    teams    = msg.from_teams = @extract_message_type(values, 'team')
    msg.from = @format_users_and_teams(users, teams)

  add_message_to: (to, msg) ->
    if @is_string(to)
      msg.to = to
      return
    values = ember.makeArray(to).compact()
    users  = msg.to_users = @extract_message_type(values, 'user')
    teams  = msg.to_teams = @extract_message_type(values, 'team')
    msg.to = @format_users_and_teams(users, teams)

  extract_message_type: (array, type) ->
    return [] if ember.isBlank(array) or not ember.isArray(array)
    array.filterBy 'type', type
