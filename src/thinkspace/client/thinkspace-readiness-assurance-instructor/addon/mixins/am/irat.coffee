import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  send_irat_to_trat:      (data) -> @send_irat_request(data, 'to_trat')
  send_irat_phase_states: (data) -> @send_irat_request(data, 'phase_states')

  send_irat_request: (data, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query @get_irat_url(action), data
      ajax.object(query).then =>
        resolve()

  get_irat_url:  (action) -> ns.to_p('readiness_assurance', 'irats', action)
