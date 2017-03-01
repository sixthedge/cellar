import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend
  tagName:    'li'
  classNames: ['ts-ra_question']

  actions:
    select_answer:      (id)    -> @qm.save_answer(id); @validate_answer()
    save_justification: (value) -> @qm.save_justification(value).then => @qm.unlock()
    focus_justification:        -> @qm.lock()

    cancel_justification: ->
      @qm.reset_values()
      @qm.unlock()

    toggle_chat: ->
      if @toggleProperty 'qm.chat_displayed'
        @sendAction 'chat', @qm.qid
      else
        @sendAction 'chat_close', @qm.qid

  init_base: ->
    @tvo_status_register_callback(@, 'submit_validate')
    @tvo_status_messages_title 'You must answer the the following questions:'
    vpresence = totem_changeset.vpresence(presence: true, message: 'You must select one of the choices')
    @set 'changeset', totem_changeset.create @qm, answer_id: [vpresence]
    @validate_answer()

  validate_answer: ->
    changeset = @get('changeset')
    changeset.set 'answer_id', @qm.get('answer_id')
    changeset.validate().then => changeset.get('is_valid')

  submit_validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_answer().then =>
        changeset = @get('changeset')
        return resolve() if changeset.get('is_valid')
        resolve @qm.get('question')
