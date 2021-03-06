import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend
  # # Properties
  tagName:           'li'
  classNames:        ['ts-ra_question']
  classNameBindings: ['is_readonly']

  # # Computed Properties
  is_readonly: ember.computed.or 'qm.readonly', 'qm.answers_disabled'

  # # Events
  init_base: ->
    @tvo_status_register_callback(@, 'submit_validate')
    @tvo_status_messages_title 'You must answer the the following questions:'
    vpresence = totem_changeset.vpresence(presence: true, message: 'You must select one of the choices')
    @set 'changeset', totem_changeset.create @qm, answer_id: [vpresence]
    @validate_answer()

  # # Helpers
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

  actions:
    select_answer:      (id)    -> @qm.save_answer(id); @validate_answer()
    save_justification: (value) -> @qm.save_justification(value)
