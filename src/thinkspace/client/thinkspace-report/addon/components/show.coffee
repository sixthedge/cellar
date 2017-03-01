import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

export default base.extend

  token: ember.computed.reads 'query_params_controller.token'

  actions:
    back: ->
      @get('model.authable').then (authable) =>
        @get('thinkspace').transition_to_model_route(authable, 'reports')

  init_base: ->
    @get_report().then => @set_all_data_loaded()

  get_report: ->
    new ember.RSVP.Promise (resolve, reject) =>
      token = @get 'token'
      return unless ember.isPresent(token) # TODO: Raise a totem error?
      query =
        action: 'access'
        verb:   'get'
        model:  ns.to_p('report:report')
        data:
          report_token: token
      @totem_messages.show_loading_outlet(message: 'Requesting report...')
      ajax.object(query).then (payload) =>
        report = @tc.push_payload_and_return_data_record(payload)
        @set 'model', report
        @totem_messages.hide_loading_outlet()
        resolve()
