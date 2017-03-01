import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  willInsertElement: -> @cm.init_values()

  actions:
    send: ->
      @cm.add_message()

    close: ->
      @qm.set_chat_displayed_off()
      @sendAction 'close', @cm.qid
