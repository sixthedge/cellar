import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  send_timer_cancel: (data) ->
    return if ember.isBlank(data)
    @send_timer_request(data, 'cancel')

  send_timer_request: (data, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query @get_timer_url(action), data
      ajax.object(query).then =>
        resolve()

  get_timer_url: (action) -> ns.to_p('readiness_assurance', 'timers', action)
