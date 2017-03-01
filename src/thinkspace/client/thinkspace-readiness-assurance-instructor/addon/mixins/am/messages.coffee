import ember       from 'ember'
import ns          from 'totem/ns'
import ajax        from 'totem/ajax'

export default ember.Mixin.create

  send_message_to_users: (data) -> @send_message('to_users', data)

  send_message: (action, data={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query @get_messages_url(action), data
      ajax.object(query).then =>
        resolve()

  get_messages_url: (action) -> ns.to_p('readiness_assurance', 'messages', action)
