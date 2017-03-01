import ember from 'ember'

export default ember.Mixin.create

  pubsub: ember.inject.service()

  current_users: []
  users_added:   []
  users_removed: []

  collapsed:            false
  show_number_of_users: true
  number_of_users:      0
  number_of_all_users:  0
  all_sorted_users:     null

  room:          'override_in_component'
  room_type:     'user_list'
  get_room_type: -> @get('room_type')
  get_room:      -> @get('room')

  get_name: (user) -> "#{user.last_name}, #{user.first_name}"

  actions:
    toggle_collapsed: -> @toggleProperty('collapsed'); return
    refresh:          -> @refresh_users()

  refresh_users: ->
    room      = @get_room()
    room_type = @get_room_type()
    event     = @get('pubsub').client_event(room_type)
    @get('pubsub').message_to_room_members(event, room, {room_type})

  set_all_sorted_users: ->
    users            = @get('users')
    all_sorted_users = []
    if ember.isPresent(users)
      for user in users
        id           = user.id
        name         = @get_name(user)
        present      = false
        current_user = @get('pubsub').is_current_user_id(id)
        all_sorted_users.push({id, name, present, current_user})
    @set 'all_sorted_users', all_sorted_users.sortBy 'name'

  handle_room_users: (data) ->
    user_list     = data.user_list or []
    current_users = @get('current_users')
    users_added   = []
    users_removed = []
    users         = []
    for user in user_list
      unless @get('pubsub').is_current_user_id(user.id)
        users_added.push(user) unless current_users.findBy 'id', user.id
      user.name = @get_name(user)
      users.push(user)
    for user in current_users
      users_removed.push(user) unless users.findBy 'id', user.id
    for user in @all_sorted_users
      ember.set user, 'present', ember.isPresent users.findBy('id', user.id)
    @set 'users_added',             users_added
    @set 'users_removed',           users_removed
    @set 'current_users',           users
    @set 'number_of_users',         users.length
    @set 'number_of_all_users',     @all_sorted_users.length
    @set 'number_of_users_changed', (users_added.length + users_removed.length)
    @number_of_users_changed_animation()

  number_of_users_changed_animation: ->
    return if @get('number_of_users_changed') == 0
    @set 'show_number_of_users', false
    ember.run.schedule 'afterRender', => @set 'show_number_of_users', true
