import ember from 'ember'
import ds    from 'ember-data'
import ta    from 'totem/ds/associations'
import m_msg from 'totem-messages/mixins/models/message'

export default ta.Model.extend m_msg,

  messages: ember.inject.service ta.to_p('casespace', 'messages')

