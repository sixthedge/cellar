import ember          from 'ember'
import ajax           from 'totem/ajax'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  join_status_received_event: -> @join_room_event(@, 'status')

  handle_status: (data) ->
    console.info 'received status--->', data
    value  = data.value or {}
    status = value.status
    qid    = value.question_id
    @error "Received status 'status' is blank."     if ember.isBlank(status)
    @error "Received chat 'question_id' is blank."  if ember.isBlank(qid)
    qm = @question_manager_map.get(qid)
    @error "Received status 'question manager' for question_id '#{qid}' not found."  if ember.isBlank(qm)
    qm.handle_status(status)

  save_status: (question_id, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @readonly
      unless @save_to_server
        @save_off_message(@status)
        return resolve()
      model = @status
      id    = @status.get('id')
      verb  = 'post'
      data  = {question_id}
      ajax.object({verb, model, id, action, data}).then =>
        resolve()
