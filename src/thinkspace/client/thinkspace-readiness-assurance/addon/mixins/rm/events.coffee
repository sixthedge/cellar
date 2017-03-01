import ember from 'ember'

export default ember.Mixin.create

  # Currently only server-events for assignment/current_user are used.
  join_server_event_received_event: ->
    @se.join_assignment_with_current_user() unless @is_admin
