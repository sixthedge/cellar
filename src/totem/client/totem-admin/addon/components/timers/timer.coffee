import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''
  refresh: 'refresh'

  admin: ember.inject.service()

  show_cancel_timer_prompt: false
  error_message:            null

  show_users: false

  actions:
    cancel: -> @set 'show_cancel_timer_prompt', true
    done:   -> @set 'show_cancel_timer_prompt', false; @set 'error_message', null

    toggle_users: -> @toggleProperty 'show_users'; return

    cancel_timer: ->
      am = @get('admin')
      am.send_timer_cancel(@timer).then =>
        @set 'show_cancel_timer_prompt', false
        @sendAction 'refresh'
      , (error) =>
        @set 'error_message', am.server_error_message(error)

