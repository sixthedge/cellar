import ember  from 'ember'
import util   from 'totem/util'
import config from 'totem-config/config'
import {env}  from 'totem-config/config'

export default ember.Mixin.create

  session: ember.inject.service()

  init: ->
    @io            = window.io
    @pubsub_active = ember.isPresent(@io)
    return unless @pubsub_active
    console.warn "socket.io (at: window.io) is blank. Pubsub is inactive."  unless @pubsub_active
    @session = @get('session')
    @set_debugging()

  get_socket: (options={}) -> @pubsub_active and @auth_socket(options)

  get_non_auth_socket: (options={}) -> @pubsub_active and @non_auth_socket(options)

  invalidate_socket: (socket) ->
    return unless @pubsub_active
    socket.disconnect()
    socket.destroy()

  get_pubsub_url: (options={}) ->
    pubsub = config.pub_sub or {}
    ns     = pubsub.namespace
    url    = options.url or pubsub.socketio_url
    @error("Pubsub url is blank.")        unless url
    @error("Pubsub namespace is blank.")  unless ns
    ns  = '/' + ns  unless util.starts_with(ns, '/')
    url + ns

  set_debugging: ->
    return unless (env.environment and env.environment == 'development')
    @debugging_delete_events = false

  toString: -> 'TotemPubSub'
