import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  message_present: ember.computed.bool  'totem_messages.message_present'
  messages:        ember.computed.reads 'totem_messages.message_queue'
  is_debug:        ember.computed.bool  'totem_messages.debug_on'

  # init_base: ->
  #   @totem_messages.error "ERROR TEST MESSAGE 1"
  #   # @totem_messages.error "ERROR TEST MESSAGE 2"
  #   # @totem_messages.warn "WARN TEST MESSAGE 1"
  #   # @totem_messages.info "INFO TEST MESSAGE 1"
