import ember from 'ember'

export default ember.Mixin.create

  # ###
  # ### Public API.
  # ###

  # Return a socket without authenticate and authorize events.
  non_auth_socket: (options={}) ->
    return null unless @pubsub_active
    url = @get_pubsub_url(options)
    @error("Pubsub url is blank.")  if ember.isBlank(url)
    socket = @non_auth_url_to_socket_map.get(url)
    if socket
      if socket.is_connected
        @delete_previous_non_auth_callback(@non_auth_on_connect_callback_map, options)
        @non_auth_on_connect_callback_map.set(options, socket)
        @call_non_auth_socket_callbacks(@non_auth_on_connect_callback_map)
      else
        @non_auth_on_connect_callback_map.set(options, socket)
      return socket
    socket = @io.connect(url);
    @error("Pubsub socket is blank [url: #{url}].")  unless socket
    @non_auth_on_connect_callback_map.set(options, socket)
    @non_auth_url_to_socket_map.set(url, socket)
    socket.on 'connect', =>
      socket.is_connected = true
      @call_non_auth_socket_callbacks(@non_auth_on_connect_callback_map)
    socket

  # ###
  # ### Private.
  # ###

  non_auth_url_to_socket_map:       ember.Map.create()
  non_auth_on_connect_callback_map: ember.Map.create()

  call_non_auth_socket_callbacks: (map) ->
    map.forEach (socket, options) =>
      callback = options.callback
      source   = options.source
      if @is_string(callback) and @is_active(source) and @is_function(source[callback])
        source[callback](socket, options)
      else
        map.delete(options)

  delete_previous_non_auth_callback: (map, options) ->
    callback = options.callback
    source   = options.source
    return if ember.isBlank(callback) or ember.isBlank(source)
    map.forEach (socket, map_options) =>
      map_callback = map_options.callback
      map_source   = map_options.source
      if ember.isPresent(map_callback) and ember.isPresent(map_source)
        map.delete(map_options) if callback == map_callback and source == map_source

