import ember          from 'ember'
import base           from 'thinkspace-base/components/base'
import tc             from 'totem/cache'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'


export default base.extend

  ttz: ember.inject.service()

  data: null

  has_subscription: ember.computed.reads 'data.has_sub'
  status:           ember.computed.reads 'data.sub.status'
  cur_period_start: ember.computed.reads 'data.sub.cur_period_start'
  cur_period_end:   ember.computed.reads 'data.sub.cur_period_end'
  will_end:         ember.computed.reads 'data.sub.will_end'

  subscription_active: ember.computed.equal 'status', 'active'

  friendly_period_start: ember.computed 'cur_period_start', ->
    cur_period_start = @get('cur_period_start')
    return null unless ember.isPresent(cur_period_start)
    @get('ttz').format(cur_period_start, format: 'MMMM Do')

  friendly_period_end: ember.computed 'cur_period_end', ->
    cur_period_end = @get('cur_period_end')
    return null unless ember.isPresent(cur_period_end)
    @get('ttz').format(cur_period_end, format: 'MMMM Do')

  actions:
    cancel: -> @sendAction('cancel')

    update_payment: -> @sendAction('updating_payment', true)

    reactivate: -> @sendAction('reactivate')
