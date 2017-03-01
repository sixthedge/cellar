import ember from 'ember'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend

  chat_managers: ember.computed 'chat_ids.[]', ->
    managers = []
    chat_ids = @get('chat_ids') or []
    for qid in chat_ids
      cm = @rm.chat_manager_map.get(qid)
      qm = @rm.question_manager_map.get(qid)
      util.error @, "Question manager not found for qid: #{qid}" if ember.isBlank(qm)
      util.error @, "Chat manager not found for qid: #{qid}"     if ember.isBlank(cm)
      managers.push
        cm: cm
        qm: qm
    managers

  actions:
    close: (qid) ->
      @sendAction 'close', qid
