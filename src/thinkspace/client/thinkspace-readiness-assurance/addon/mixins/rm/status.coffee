import ember          from 'ember'
import ajax           from 'totem/ajax'
import util           from 'totem/util'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  join_status_received_event: -> @join_room_event(@, 'status')

  handle_status: (data) ->
    console.info 'received status--->', data
    value = data.value or {}
    @error "Received status value is not a hash.", data unless util.is_hash(value)
    questions = value.questions
    @error "Received status value.questions is not a hash.", data unless util.is_hash(questions)
    qids = util.hash_keys(questions)
    for qid in qids
      status = questions[qid] or {}
      qm     = @question_manager_map.get(qid)
      @error "Received status 'question manager' for question_id '#{qid}' not found."  if ember.isBlank(qm)
      qm.handle_status(status)

  save_status: (action, question_id=null) ->
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
      , (error) =>
        @error 'Save status error.', {error, question_id, action, id, model}
