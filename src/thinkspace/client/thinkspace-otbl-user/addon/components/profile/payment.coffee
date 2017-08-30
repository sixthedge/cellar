import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import tc    from 'totem/cache'


export default base.extend

  display_payment: ember.computed 'is_updating_payment', 'has_sub', ->
    console.log('is_updating_payment? has_sub? ', @get('is_updating_payment'), @get('has_sub'))
    @get('is_updating_payment') || !@get('has_sub')

  has_sub:             ember.computed.reads 'sub_data.has_sub'
  is_updating_payment: false

  init_base: -> 
    @set_loading('all')
    @init_sub_status().then =>
      @reset_loading('all')

  init_sub_status: ->
    new ember.RSVP.Promise (resolve, reject) =>
      options = 
        verb:   'POST'
        action: 'subscription_status'

      tc.query_data(ns.to_p('customer'), {}, options).then (data) =>
        @set('sub_data', data)
        resolve()
      , (error) => console.warn('[thinkspace-stripe] Payment status update unsuccessful.')

  cancel_subscription: ->
    new ember.RSVP.Promise (resolve, reject) =>
      options = 
        verb:   'POST'
        action: 'cancel'

      tc.query_data(ns.to_p('customer'), {}, options).then =>
        resolve()

  reactivate_subscription: ->
    new ember.RSVP.Promise (resolve, reject) =>
      options =
        verb:   'POST'
        action: 'reactivate'

      tc.query_data(ns.to_p('customer'), {}, options).then =>
        resolve()

  actions:
    updating_payment: (bool) -> 
      @set('is_updating_payment', bool)
      false

    cancel: -> 
      @cancel_subscription().then =>
        @init_sub_status()
      false

    update: ->
      @init_sub_status()
      false

    reactivate: ->
      @reactivate_subscription().then =>
        @init_sub_status()
      false
