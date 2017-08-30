import ember          from 'ember'
import base           from 'thinkspace-base/components/base'
import tc             from 'totem/cache'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'


export default base.extend

  plan: 'teacher'

  didInsertElement: -> @init_stripe()

  init_stripe: ->
    stripe   = Stripe('pk_test_zZUgYO5aFHAIohHEFGimNtzv')
    elements = stripe.elements()
    @set('stripe', stripe)
    @set('elements', elements)

    @init_card()
    @init_form()

  init_card: ->
    elements = @get('elements')
    card     = elements.create('card')

    card.mount('#card-element')
    card.addEventListener 'change', (event) ->
      display_error = document.getElementById('card-errors')

      if ember.isPresent(event.error)
        display_error.textContent = event.error.message
      else
        display_error.textContent = ''
      return
    @set('card', card)

  init_form: ->
    stripe = @get('stripe')
    card   = @get('card')
    form   = document.getElementById('payment-form')
    form.addEventListener 'submit', (event) =>
      event.preventDefault()
      stripe.createToken(card).then (result) =>
        if result.error
          errorElement             = document.getElementById('card-errors')
          errorElement.textContent = result.error.message
        else
          @submit_token_handler(result.token)

        return false
      return false
 
  submit_token_handler: (token) ->
    query   = 
      stripe_token: token
      plan_id:      @get('plan')
    
    options =
      verb: 'POST'

    @set_loading('submit')
    tc.query_data(ns.to_p('customer'), query, options).then =>
      @reset_loading('submit')
      totem_messages.api_success source: @, action: 'create', i18n_path: ns.to_o('customer', 'card_saved')
      @sendAction('update')
      return true
    , (error) =>
      ## Error display handled by api
      @reset_loading('submit')
      console.warn('[thinkspace-stripe] Card detail submission unsuccessful. ', error)

  actions:
    updating_payment: -> @sendAction('updating_payment', false)
