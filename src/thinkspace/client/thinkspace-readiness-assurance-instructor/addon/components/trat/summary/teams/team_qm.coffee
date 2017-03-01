import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  tagName: ''

  chat_messages: ember.computed.reads 'cm.messages'

  init_base: ->
    @qid = @qm.qid
    @rm  = @qm.rm
    @cm  = @rm.chat_manager_map.get(@qid)
