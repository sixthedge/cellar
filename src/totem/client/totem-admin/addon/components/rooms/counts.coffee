import ember  from 'ember'
import util   from 'totem/util'
import base   from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,

  admin: ember.inject.service()

  ready:            false
  has_room_counts:  false
  show_confirm_all: false
  room_counts:      null

  sorted_room_counts: ember.computed.sort 'room_counts', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      room:  {id: 'room', sort: 'sort_room', text: 'Room'}
      count: {id: 'count', sort: 'sort_count', text: 'Count'}

  actions:
    refresh:   -> @am.emit_room_counts(@)
    confirm:   -> @confirm()
    hide:      -> @hide()

    reset: (room, count=0) -> @am.emit_room_count_reset({room, count})
    reset_all:             -> @am.emit_room_count_reset(room: '*'); @hide()

  init: ->
    @_super(arguments...)
    @am = @get('admin')
    @set_default_sort_by ['room']
    @am.room_counts(@)

  didInsertElement: -> @get('admin').set_other_header_links_inactvie('rooms')

  confirm: -> @toggleProperty('show_confirm_all'); return
  hide:    -> @set('show_confirm_all', false)

  handle_room_counts: (data) ->
    console.info '=> room counts', data
    data_hash   = if util.is_hash(data) then data else {}
    room_counts = []
    for room, count of data_hash
      hash = {room, count}
      @make_sortable(hash)
      room_counts.push(hash)
    @set 'room_counts', room_counts
    @set 'has_room_counts', ember.isPresent(room_counts)
    @notifyPropertyChange 'sorted_room_counts'
    @set 'ready', true

  make_sortable: (hash) ->
    hash.sort_room  = (hash.room or '').toLowerCase()
    hash.sort_count = 0
