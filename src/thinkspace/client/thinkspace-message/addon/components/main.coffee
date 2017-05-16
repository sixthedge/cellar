import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  show_message: true

  message_present: ember.computed.bool  'totem_messages.message_present'
  messages:        ember.computed.reads 'totem_messages.message_queue'
  is_debug:        ember.computed.bool  'totem_messages.debug_on'

  first_message: ember.computed 'totem_messages.message_queue.@each', -> @get('totem_messages.message_queue.firstObject')

  actions:

    remove_message: (message) ->
      # toggle show_message to trigger a new component to render for each new message
      @set 'show_message', false
      @totem_messages.remove_message(message)
      ember.run.schedule 'afterRender', =>
        @set 'show_message', true
