import ember from 'ember'

export default ember.Mixin.create

  broadcast: (event, value=null) -> @rm.broadcast_id_room_event(event, @qid, value)

  join_id_room_event: (source, event, callback=null) -> @rm.join_id_room_event(source, event, @qid, callback)
  join_room_event:    (source, event, callback=null) -> @rm.join_room_event(source, event, callback)
