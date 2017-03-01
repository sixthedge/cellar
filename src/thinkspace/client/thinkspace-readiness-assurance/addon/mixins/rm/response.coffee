import ember          from 'ember'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  join_response_received_event: -> @join_room_event(@, 'response')

  handle_response: (data) ->
    payload = data.value
    @tc.push_payload(payload)  if payload
    console.info 'received response--->', payload, @response
    @question_manager_map.forEach (qm) =>
      qm.reset_values()

  save_response: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @readonly
      unless @save_to_server
        @save_off_message(@response)
        return resolve()
      @response.save().then =>
        resolve()
      , (error) =>
        reject(error)
