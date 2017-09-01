import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import tc    from 'totem/cache'


export default base.extend
  # # Properties
  is_updating_payment: false

  teacher_plan: {
    title:    'Teacher Plan'
    label:    'Teacher - $30/month'
    id:       'teacher'
    cost:     30
    interval: 'month'
    currency: 'usd'
  }

  # # Computed properties
  is_teacher:      ember.computed.reads 'session.user.is_teacher'
  has_sub:         ember.computed.reads 'sub_data.has_sub'
  display_payment: ember.computed 'is_updating_payment', 'has_sub', -> @get('is_updating_payment') || !@get('has_sub')
  
  # # Events
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

  # # Helpers
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

  reset_sub_status: ->
    @set_loading('all')
    @init_sub_status().then =>
      @reset_loading('all')
      false

  actions:
    updating_payment: (bool) -> 
      @set('is_updating_payment', bool)
      false

    cancel: -> 
      @set_loading('all')
      @cancel_subscription().then =>
        @init_sub_status().then =>
          @reset_loading('all')
          false

    update: -> @reset_sub_status()

    reactivate: ->
      @set_loading('all')
      @reactivate_subscription().then =>
        @init_sub_status().then =>
          @reset_loading('all')
          false
