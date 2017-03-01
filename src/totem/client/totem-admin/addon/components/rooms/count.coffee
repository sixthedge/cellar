import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''

  value:        null
  show_count:   false
  show_confirm: false

  actions:
    zero:       -> @set_zero()
    get_count:  -> @get_count()
    set_count:  -> @set_count()
    send_reset: -> @send_reset()
    hide:       -> @hide()

  hide: ->
    @set 'show_count', false
    @set 'show_confirm', false

  set_zero: ->
    @set 'value', '0'
    @confirm()

  get_count: ->
    @set 'value', @get('room.count')
    if @toggleProperty 'show_count'
      @set 'show_confirm', false

  set_count: -> @confirm()

  confirm: ->
    @hide()
    @set 'show_confirm', true

  send_reset: ->
    @sendAction 'reset', @room.room, @get('value')
    @hide()
