import ember from 'ember'

export default ember.Mixin.create

  chat_displayed: false

  set_chat_displayed_on:  -> @set 'chat_displayed', true
  set_chat_displayed_off: -> @set 'chat_displayed', false

  answers_disabled:       false
  justification_disabled: false
  question_disabled_by:   null

  set_question_disabled_by: (value) -> @set 'question_disabled_by', value
  set_question_disabled_by_self:    -> @set 'question_disabled_by', 'yourself'

  set_answers_disabled_on:          -> @set 'answers_disabled', true
  set_answers_disabled_off:         -> @set 'answers_disabled', false
  set_justification_disabled_on:    -> @set 'justification_disabled', true
  set_justification_disabled_off:   -> @set 'justification_disabled', false

  set_question_disabled_on: ->
    @set_justification_disabled_on()
    @set_answers_disabled_on()

  set_question_disabled_off: ->
    @set_justification_disabled_off()
    @set_answers_disabled_off()

  lock: ->
    @set_question_disabled_by_self()
    @rm.save_status(@qid, 'lock').then => return

  unlock: ->
    @set_question_disabled_by(null)
    @rm.save_status(@qid, 'unlock').then => return

  handle_status: (status) ->
    @set @status_path, status
    @set_status()
