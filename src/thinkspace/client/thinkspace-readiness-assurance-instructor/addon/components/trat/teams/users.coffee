import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import user_list_mixin from 'thinkspace-readiness-assurance/mixins/user_list'

export default base.extend user_list_mixin,

  header: ember.computed.reads 'team.title'
  room:   ember.computed.reads 'team.room'
  users:  ember.computed.reads 'team_users'

  collapsed: true

  show_users: ember.observer 'show_all', -> @set 'collapsed', (not @get('show_all'))

  init_base: -> @setup()

  setup: ->
    @pubsub.join
      room:          @get_room()
      room_type:     @get_room_type()
      room_observer: true
      source:        @
      callback:      'handle_room_users'
    @set_all_sorted_users()
    @refresh_users()
