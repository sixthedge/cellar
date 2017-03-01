import ember from 'ember'
import base  from 'totem-base/components/base'
import totem_messages from 'totem-messages/messages'

export default base.extend
  tagName: ''

  actions:
    sign_out: -> totem_messages.sign_out_user()
