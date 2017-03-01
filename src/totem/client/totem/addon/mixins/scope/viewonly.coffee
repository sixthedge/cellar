import ember from 'ember'

export default ember.Mixin.create

  # Must be manually turned on/off.
  is_read_only: false
  is_disabled:  false
  is_view_only: ember.computed.or 'is_read_only', 'is_disabled'  # single convience property that or's the granular values

  read_only_on:  -> @set 'is_read_only', true
  read_only_off: -> @set 'is_read_only', false
  disabled_on:   -> @set 'is_disabled',  true
  disabled_off:  -> @set 'is_disabled',  false

  view_only_on: ->
    @read_only_on()
    @disabled_on()

  view_only_off: ->
    @read_only_off()
    @disabled_off()

