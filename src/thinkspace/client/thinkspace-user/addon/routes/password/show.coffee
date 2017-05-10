import ember from 'ember'
import ns from 'totem/ns'

export default ember.Route.extend
  titleToken: -> 'Password Reset'

  model: (params) -> @tc.find_record(ns.to_p('password_reset'), params.token)
      
  setupController: (controller, model) -> controller.set('model', model)