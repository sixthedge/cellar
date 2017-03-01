import ember from 'ember'

export default ember.Mixin.create

  default_tracker_leave_rooms_routes: ['spaces', 'users']
  default_tracker_ignore_routes:      ['users.sign_in']

  # Could set these as needed if there is a future use.
  tracker_leave_rooms_routes: null
  tracker_ignore_routes:      null

  transition_to_route: (route) ->
    return unless @pubsub_active
    @leave_all_except_tracker() if @route_tracker_leave_rooms(route)
    return if @route_tracker_ignore(route) # no user data to track
    @tracker({route})

  route_tracker_ignore: (route) ->
    return true if ember.isBlank(route)
    routes = @tracker_leave_rooms_routes or @default_tracker_ignore_routes
    @match_route(route, routes)

  route_tracker_leave_rooms: (route) ->
    return false if ember.isBlank(route)
    routes = @tracker_ignore_routes or @default_tracker_leave_rooms_routes
    @match_route(route, routes)

  match_route: (route, matches) ->
    for mroute in ember.makeArray(matches)
      return true if route.match("^#{mroute}")
    false

