import ember from 'ember'
import util  from 'totem/util'

export default ember.Component.extend
  tagName: ''

  admin: ember.inject.service()

  init: ->
    @_super(arguments...)
    @am     = @get('admin')
    @se     = @am.se
    @pubsub = @am.pubsub
    @init_base()

  init_base: -> return

  ready:         false
  selected_send: false

  get_ready:     -> @get 'ready'
  set_ready_on:  -> @set 'ready', true
  set_ready_off: -> @set 'ready', false

  selected_send_on:  -> @set 'selected_send', true
  selected_send_off: -> @set 'selected_send', false

  error: (args...) -> util.error(args...)
