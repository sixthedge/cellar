import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  init_base: ->
    qm        = @get 'qms.firstObject'
    @qid      = qm.qid
    @qnumber  = qm.qn
    @question = qm.question

  show_justification: false
  show_chat:          false

  actions:
    show_justification: -> @set 'show_justification', true
    hide_justification: -> @set 'show_justification', false

    show_chat: -> @set 'show_chat', true
    hide_chat: -> @set 'show_chat', false
