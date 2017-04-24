import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'tr'
  roles:   ['read', 'update', 'owner']

  actions:
    destroy: ->
      @get('model').destroyRecord()
      
    resend: ->
      model = @get('model')
      query =
        model:  model
        id:     model.get('id')
        action: 'resend'
        verb:   'put'
      ajax.object(query).then (payload) =>
        @tc.push_payload(ns.to_p('invitation'), payload)
        @totem_messages.api_success source: @, model: model, action: 'update', i18n_path: ns.to_o('invitation', 'save')