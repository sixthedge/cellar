import ember          from 'ember'
import ajax           from 'totem/ajax'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  join_chat_received_event: -> @join_room_event(@, 'chat')

  handle_chat: (data) ->
    console.info 'received chat--->', data, @chat
    value   = data.value or {}
    message = value.message
    qid     = value.question_id
    @error "Received chat 'message' is blank."      if ember.isBlank(message)
    @error "Received chat 'question_id' is blank."  if ember.isBlank(qid)
    cm = @chat_manager_map.get(qid)
    @error "Received chat 'chat manager' for question_id '#{qid}' not found."  if ember.isBlank(cm)
    cm.handle_chat(message)

  save_chat: (question_id, message) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @readonly
      unless @save_to_server
        @save_off_message(@chat)
        return resolve()
      model       = @chat
      id          = @chat.get('id')
      action      = 'add'
      verb        = 'post'
      data        = {question_id, message}
      ajax.object({verb, model, id, action, data}).then =>
        resolve()
