import ember from 'ember'

export default ember.Mixin.create

  server_event_room: 'server_event'

  join: (options={}) ->
    return unless @pubsub_active
    room       = options.room
    source     = options.source or @
    callback   = options.callback or 'handle_server_event'
    room_event = options.room_event or @server_event_room
    @pubsub.join {room, source, callback, room_event}

  leave: (options={}) ->
    return unless @pubsub_active
    rooms = options.rooms
    return unless rooms
    room_type = options.room_type
    @pubsub.leave({rooms, room_type})

  leave_all: (options={}) -> @pubsub_active and @pubsub.leave_all(options)

  # ###
  # ### Current Model Room Helpers.
  # ###

  current_model_room:              (args...) -> @pubsub.room_for(@thinkspace.get_current_model(), args...)
  current_model_current_user_room: (args...) -> @pubsub.room_with_current_user(@thinkspace.get_current_model(), args...)
  current_model_ownerable_room:    (args...) -> @pubsub.room_with_ownerable(@thinkspace.get_current_model(), args...)

  get_current_model: -> @thinkspace.get_current_model()

  # ###
  # ### Room Helpers.
  # ###

  space_room:                   (args...) -> @pubsub.room_for(@get_space(), args...)
  space_ownerable_room:         (args...) -> @pubsub.room_with_ownerable(@get_space(), args...)
  space_current_user_room:      (args...) -> @pubsub.room_with_current_user(@get_space(), args...)
  assignment_room:              (args...) -> @pubsub.room_for(@get_assignment(), args...)
  assignment_ownerable_room:    (args...) -> @pubsub.room_with_ownerable(@get_assignment(), args...)
  assignment_current_user_room: (args...) -> @pubsub.room_with_current_user(@get_assignment(), args...)
  phase_room:                   (args...) -> @pubsub.room_for(@get_phase(), args...)
  phase_ownerable_room:         (args...) -> @pubsub.room_with_ownerable(@get_phase(), args...)
  phase_current_user_room:      (args...) -> @pubsub.room_with_current_user(@get_phase(), args...)

  # ###
  # ### Join Helpers.
  # ###

  join_space:                        (options={}) -> options.room = @space_room();                   @join(options)
  join_space_with_ownerable:         (options={}) -> options.room = @space_ownerable_room();         @join(options)
  join_space_with_current_user:      (options={}) -> options.room = @space_current_user_room();      @join(options)
  join_assignment:                   (options={}) -> options.room = @assignment_room();              @join(options)
  join_assignment_with_ownerable:    (options={}) -> options.room = @assignment_ownerable_room();    @join(options)
  join_assignment_with_current_user: (options={}) -> options.room = @assignment_current_user_room(); @join(options)
  join_phase:                        (options={}) -> options.room = @phase_room();                   @join(options)
  join_phase_with_ownerable:         (options={}) -> options.room = @phase_ownerable_room();         @join(options)
  join_phase_with_current_user:      (options={}) -> options.room = @phase_current_user_room();      @join(options)

  join_phase_or_assignment: (options={}) -> if ember.isPresent(@get_phase()) then join_phase(options) else join_assignment(options)

  # ###
  # ### Leave Helpers.
  # ###

  leave_all_except_space_room:                   (options={}) -> options.except = @space_room();                   @leave_all(options)
  leave_all_except_space_ownerable_room:         (options={}) -> options.except = @space_ownerable_room();         @leave_all(options)
  leave_all_except_space_current_user_room:      (options={}) -> options.except = @space_current_user_room();      @leave_all(options)
  leave_all_except_assignment_room:              (options={}) -> options.except = @assignment_room();              @leave_all(options)
  leave_all_except_assignment_ownerable_room:    (options={}) -> options.except = @assignment_ownerable_room();    @leave_all(options)
  leave_all_except_assignment_current_user_room: (options={}) -> options.except = @assignment_current_user_room(); @leave_all(options)
  leave_all_except_phase_room:                   (options={}) -> options.except = @phase_room();                   @leave_all(options)
  leave_all_except_phase_ownerable_room:         (options={}) -> options.except = @phase_ownerable_room();         @leave_all(options)
  leave_all_except_phase_current_user_room:      (options={}) -> options.except = @phase_current_user_room();      @leave_all(options)
  leave_all_except_tracker:                      (options={}) -> options.except = @get_tracker_room();             @leave_all(options)

  # ###
  # ### Instructor Helpers.
  # ###

  get_admin_room: -> @assignment_room('admin')

  join_admin_room:             -> @join room: @get_admin_room()
  leave_all_except_admin_room: -> @leave_all(except: @get_admin_room())

  # ###
  # ### Current Model Helpers.
  # ###

  get_space: ->
    space = @thinkspace.get_current_space()
    @error "Cannot join space server events.  Space is blank."  if ember.isBlank(space)
    space

  get_assignment: ->
    assignment = @thinkspace.get_current_assignment()
    @error "Cannot join assignment server events.  Assignment is blank."  if ember.isBlank(assignment)
    assignment

  get_phase: ->
    phase = @thinkspace.get_current_phase()
    @error "Cannot join phase server events.  Phase is blank."  if ember.isBlank(phase)
    phase
