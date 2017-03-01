import ember  from 'ember'
import util   from 'totem/util'
import base   from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,

  admin: ember.inject.service()

  ready:     false
  user_data: null
  has_users: false

  sorted_user_data: ember.computed.sort 'user_data', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      user: {id: 'user', sort: 'sort_username', text: 'User'}
      room: {id: 'room', sort: 'sort_room', text: 'Room'}
      url:  {id: 'url', sort: 'sort_url', text: 'Tracker URL'}
      sid:  {id: 'sid', sort: 'sid', text: 'Socket ID'}

  actions:
    refresh: -> @am.emit_room_list(@)

  init: ->
    @_super(arguments...)
    @am = @get('admin')
    @set_default_sort_by ['user', 'room']
    @am.room_list(@)

  didInsertElement: -> @get('admin').set_other_header_links_inactvie('rooms')

  handle_room_list: (data) ->
    console.info ' => room list', data
    rooms = util.hash_keys(data) or []
    users = []
    for room in rooms
      room_users = data[room]
      @set_room_users(users, room, room_users)
    @set 'user_data', users
    @set 'has_users', ember.isPresent(users)
    @notifyPropertyChange 'sorted_user_data'
    @set 'ready', true

  set_room_users: (users, room, room_users) ->
    for hash in room_users
      user            = {}
      user.room       = room
      user.id         = hash.id
      user.username   = hash.username
      user.first_name = hash.first_name
      user.last_name  = hash.last_name
      user.url        = hash.href or ''
      user.sid        = hash.sid
      @make_user_sortable(user)
      users.push(user)

  make_user_sortable: (user) ->
    user.sort_username = (user.username or '').toLowerCase()
    user.sort_room     = (user.room or '').toLowerCase()
    user.sort_url      = (user.url or '').toLowerCase()
