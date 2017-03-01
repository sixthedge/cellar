import ember from 'ember'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  generated_tracker_sid: null
  tracker_room:          'tracker_sio_room'

  # A node socketio tracker is generated via a Rails server publish to Redis.
  # The authenticated socket.id is send to the Rails server and if authorized,
  # the Rails server publishes a Redis request to setup the tracker.

  tracker_show: (component) ->
    options =
      after_authenticate_callback: 'tracker_after_authenticate_callback'
      source:                      @
      component:                   component
    @pubsub.get_socket(options) # authenticate the user and ensure the socket id is present.

  tracker_after_authenticate_callback: (options) -> @send_tracker_authorize().then => @emit_tracker_show(options.component)

  emit_tracker_show: (source) ->
    socket  = @get_tracker_socket()
    options = 
      socket:   socket
      room:     @tracker_room
      callback: 'handle_tracker_show'
      source:   source
    @pubsub.tracker_sio_show(options)

  send_tracker_authorize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      socket = @get_tracker_socket()
      @error "Attempting to add as tracker but socket is blank." if ember.isBlank(socket)
      return resolve() if socket.id == @get('generated_tracker_sid')
      data          = {all_rooms: true}
      tracker       = data.tracker = {}
      tracker.rooms = @tracker_room
      tracker.sid   = socket.id
      url           = @get_pubsub_url()
      verb          = 'post'
      query         = {url, verb, data}
      ajax.object(query).then =>
        @set 'generated_tracker_sid', socket.id
        resolve()

  get_tracker_socket: -> @pubsub.get_socket() # get the 'authenticated' socket

  get_pubsub_url: ->
    platform = @get_platform()
    "#{platform}/pub_sub/server_events/tracker"
