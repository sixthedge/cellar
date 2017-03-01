import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  send_trat_phase_states: (data) -> @send_trat_request(data, 'phase_states')

  send_trat_request: (data, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query @get_trat_url(action), data
      ajax.object(query).then =>
        resolve()

  get_trat_url:  (action) -> ns.to_p('readiness_assurance', 'trats', action)
