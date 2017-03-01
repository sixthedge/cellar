import ember from 'ember'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  tracker_sent: false

  is_tracker: -> @get('tracker_sent')

  send_tracker: (options={})->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @is_tracker()
      socket = @pubsub.get_socket()
      @error "Attempting to add as tracker but socket is blank." if ember.isBlank(socket)
      tracker           = {}
      tracker.rooms     = options.rooms or options.room or @se.get_tracker_room()
      tracker.sid       = socket.id
      tracker.room_type = options.room_type or 'tracker'
      query             = @get_auth_query @get_tracker_url('tracker'), {tracker}

      ajax.object(query).then =>
        @set 'tracker_sent', true
        resolve()

  get_tracker_url: (action) -> @se.get('pubsub_url') + "/#{action}"
