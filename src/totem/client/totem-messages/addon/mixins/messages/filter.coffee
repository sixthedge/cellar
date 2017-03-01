import ember from 'ember'
import util  from 'totem/util'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_new_messages_filter: (rooms=null)      -> @get_messages_filter('is_new', rooms)
  get_previous_messages_filter: (rooms=null) -> @get_messages_filter('is_previous', rooms)
  
  move_all_new_to_previous: (rooms=null) -> @move_all_to_previous('is_new', rooms)

  move_all_to_previous: (msg_prop='is_new', rooms=null) ->
    type  = @get_filter_model_type()
    rooms = ember.makeArray(rooms).compact()
    @get_filter_store().peekAll(type).forEach (message) =>
      message.set_previous() if @include_message(message, msg_prop, rooms)

  move_all_to_inactive: (msg_prop='is_previous', rooms=null) ->
    type  = @get_filter_model_type()
    rooms = ember.makeArray(rooms).compact()
    @get_filter_store().peekAll(type).forEach (message) =>
      message.set_inactive() if @include_message(message, msg_prop, rooms)

  get_messages_filter: (msg_prop='is_new', rooms=null) ->
    new ember.RSVP.Promise (resolve, reject) =>
      rooms = ember.makeArray(rooms).compact()
      type  = @get_filter_model_type()
      @get_filter_store().filter(type, (message) =>
        @include_message(message, msg_prop, rooms)).then (filter) => resolve(filter)

  get_filter_store:      -> totem_scope.get_store()
  get_filter_model_type: -> @message_model_type

  include_message: (message, msg_prop, rooms=null) ->
    return true if ember.isBlank(msg_prop)
    return false unless message.get(msg_prop)
    return true  if ember.isBlank(rooms)
    msg_rooms = message.get('rooms')
    return false if ember.isBlank(msg_rooms)
    msg_rooms = ember.makeArray(msg_rooms)
    @in_rooms(rooms, msg_rooms)

  in_rooms: (rooms, msg_rooms) ->
    for room in msg_rooms
      return true if rooms.includes(room)
    false
