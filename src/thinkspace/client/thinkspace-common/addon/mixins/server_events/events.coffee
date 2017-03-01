import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  handle_server_event: (data, socketio_event) ->
    value       = data.value or {}
    event       = value.event
    rooms       = @get_data_rooms(data) or @get_socketio_event_room(socketio_event)
    value.rooms = rooms
    console.info 'received server_event--->', {event, rooms, data}
    switch event
      when 'transition_to_phase'  then @event_transition_to_phase(value, socketio_event)
      when 'phase_states'         then @event_phase_states(value, socketio_event)
      when 'message'              then @event_message(value, socketio_event)

  # ###
  # ### Events.
  # ###

  event_transition_to_phase: (value, socketio_event) ->
    @load_records_into_store(value).then =>
      @change_phase_states(value).then =>
        @transition_to_phase(value.transition_to_phase_id)

  event_phase_states: (value, socketio_event) ->
    @load_records_into_store(value).then =>
      @change_phase_states(value).then =>
        return

  event_message: (value, socketio_event) ->
    console.info 'recevied assignment message:', {value, socketio_event}
    return if ember.isBlank(value)
    @messages.add(value)

  # ###
  # ### Transition to Phase.
  # ###

  transition_to_phase: (phase_id) ->
    return if ember.isBlank(phase_id)
    @find_phase(phase_id).then (phase) =>
      @thinkspace.transition_to_phase(phase)

  change_phase_states: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(value)
      lock_phase_ids     = value.lock_phase_ids or []
      complete_phase_ids = value.complete_phase_ids or []
      unlock_phase_ids   = value.unlock_phase_ids or []
      @lock_phase_states(lock_phase_ids).then =>
        @complete_phase_states(complete_phase_ids).then =>
          @unlock_phase_states(unlock_phase_ids).then =>
            current_phase = @thinkspace.get_current_phase()
            return resolve() if ember.isBlank(current_phase)
            phase_id = parseInt current_phase.get('id')
            switch
              when lock_phase_ids.includes(phase_id)     then @thinkspace.transition_to_current_assignment()
              when complete_phase_ids.includes(phase_id) then @regenerate_phase_view()
              when unlock_phase_ids.includes(phase_id)   then @regenerate_phase_view()
            resolve()

  lock_phase_states:     (ids) -> @update_phase_states('lock', ids)
  unlock_phase_states:   (ids) -> @update_phase_states('unlock', ids)
  complete_phase_states: (ids) -> @update_phase_states('complete', ids)

  update_phase_states: (fn, phase_ids) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(phase_ids)
      for phase_id in ember.makeArray(phase_ids)
        @get_phase_states(phase_id).then (phase_states) =>
          phase_states.forEach (phase_state) => phase_state[fn]()
          resolve()

  get_phase_states: (phase_id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve([]) if ember.isBlank(phase_id)
      @find_phase(phase_id).then (phase) =>
        if ember.isPresent(phase)
          resolve @phase_manager.map.get_current_user_phase_states(phase)
        else
          resolve []

  regenerate_phase_view: -> @phase_manager.generate_view()

  find_phase: (id) -> @find_record(ns.to_p('phase'), id)

