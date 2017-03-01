import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  tagName: ''

  send_message: false

  actions:

    toggle_send_message: ->
      if @get('send_message')
        @send 'done'
      else
        @rad = @am.rad(name: 'MSG')
        @rad.set 'users', [@user]
        @set 'send_message', true

    send: ->
      message = @rad.get_data()
      @am.send_message_to_users({message})
      @send 'done'

    done: -> @set 'send_message', false
