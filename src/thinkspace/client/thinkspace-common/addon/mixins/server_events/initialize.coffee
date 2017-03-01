import ember from 'ember'
import totem_scope from 'totem/scope'
import m_msgs from 'totem-messages/mixins/messages/base'

export default ember.Mixin.create

  phase_manager: ember.inject.service()
  pubsub:        ember.inject.service()

  message_model_type: 'thinkspace/casespace/message'
  pubsub_url:         'thinkspace/pub_sub/server_events'

  totem_messages_object: ember.Object.extend(m_msgs)
  filter_rooms:          null

  init: ->
    @_super(arguments...)
    @pubsub_active = @get('pubsub.pubsub_active')
    @warn '[WARNING] You are attempting to use the "server_events" service but pubsub is inactive.' unless @pubsub_active
    @store         = @get('store')
    @thinkspace    = @get('thinkspace')
    @pubsub        = @get('pubsub')
    @phase_manager = @get('phase_manager')
    @set_messages_object()

  reset_all: -> @leave_all()

  get_current_user: -> totem_scope.get_current_user()

  get_filter_rooms:         -> ember.makeArray(@get 'filter_rooms').compact().copy()
  set_filter_rooms: (rooms) -> @set 'filter_rooms', rooms
  clear_filter_rooms: -> @set_filter_rooms(null)

  set_messages_object: ->
    model_type = @get('message_model_type')
    load_url   = @get('pubsub_url')
    return if ember.isBlank(model_type) or ember.isBlank(load_url)
    @messages = @totem_messages_object.create
      container:          @container
      message_model_type: model_type
      message_load_url:   load_url + '/load_messages'

  get_totem_scope: -> totem_scope

  toString: -> 'ServerEvents'
