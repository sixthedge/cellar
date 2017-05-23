import ember  from 'ember'
import util   from 'totem/util'
import config from 'totem-config/config'
import api    from 'totem-messages/api'
import totem_error from 'totem/error'

totem_messages = ember.Object.extend

  # ### Initialize/setup ### #
  init: ->
    @_super()
    @reset_elapsed_time()
    @set_type_visibility(type, true) for type in @all_message_types()  # default to visible
    @api = api
    @api.set_app_msgs(@)

  # ###
  # ### Api Success/Failure.
  # ###
  api_success:  (options={}) ->
    @reset_session_timer()
    return (options.return or options.model or null)  if @suppress_all_messages()
    @api.success(options)

  api_failure:  (error, options={}) -> @api.failure(error, options)

  # ###
  # ### Message Queues.
  # ###
  info:  (message, sticky=false) -> @add_message(@message_type.info,  message, sticky)
  warn:  (message, sticky=true) -> @add_message(@message_type.warn,  message, sticky)
  error: (message, sticky=true) -> @add_message(@message_type.error, message, sticky)
  debug: (message, sticky=true) -> @add_message(@message_type.debug, message, sticky)
  fatal: (message, sticky=true) -> @add_message(@message_type.fatal, message, sticky)

  # ###
  # ### Message Queue Actions.
  # ###
  hide_type:  (type) -> @toggle_visibility(type)
  show_type:  (type) -> @toggle_visibility(type)
  clear_type: (type) -> @all_messages().removeObjects @type_messages(type)
  hide_all:          -> @hide_all_messages()
  show_all:          -> @show_all_messages()
  clear_all:         -> @all_messages().clear()

  # ###
  # ### Sign Out => convience method to call sign_out action on application route.
  # ###
  sign_out_user: -> @get_app_route().send 'sign_out'

  # ###
  # ### Totem Message Outlet.
  # ###
  show_message_outlet: (options={}) -> @get_app_controller().totem_message_outlet(options)
  hide_message_outlet:              -> @get_app_route().send 'hide_totem_message_outlet'

  # ### TOTEM MESSAGE OUTLET LOADING Public functions ### #
  loading_outlet_visible: false
  show_loading_outlet: (options={}) ->
    return if @get 'loading_outlet_visible'
    options.template_name   ?= config.messages.loading_template
    options.outlet_messages ?= options.messages or options.message
    @set 'loading_outlet_visible', true
    @message_outlet(options)
    if options.function
      obj = options.object
      totem_error.throw(@, "Cannot call show_loading_outlet with a function and a blank [options.object] value.")  unless obj
      ember.run.sync()
      ember.run.later obj, options.function, options.params, (options.interval or 1)
  hide_loading_outlet: ->
    return unless @get 'loading_outlet_visible'
    @set 'loading_outlet_visible', false
    @hide_message_outlet()

  # Open the message_outlet with this template name.
  message_outlet: (options) ->
    template_name = options.template_name
    totem_error.throw(@, "Message outlet template name is blank")  unless template_name
    @show_message_outlet(options)

  # Debug Elapsed Time.
  reset_elapsed_time: -> @set('last_message_date', util.current_date())

  #
  # Functions below are not called directly outside of totem_messages.
  #

  message_queue: []

  message_type:
    all:   'all'
    info:  'info'
    warn:  'warn'
    error: 'error'
    debug: 'debug'
    fatal: 'fatal'

  last_message_date: null

  message_type_visible: ember.Object.create()

  message_present: ember.computed 'message_queue.length', ->  @all_messages().get('length')
  info_present:    ember.computed 'message_queue.length', ->  @type_messages(@message_type.info).length  > 0
  warn_present:    ember.computed 'message_queue.length', ->  @type_messages(@message_type.warn).length  > 0
  error_present:   ember.computed 'message_queue.length', ->  @type_messages(@message_type.error).length > 0
  debug_present:   ember.computed 'message_queue.length', ->  @type_messages(@message_type.debug).length > 0
  debug_on:        ember.computed -> util.log_debug()

  container:                  null
  application_route:          null
  application_controller:     null
  session_timeout_controller: null

  # App container (set by initializer).
  get_container:             -> @get('container')
  set_container: (container) -> @set('container', container)
  container_lookup: (name)   -> @get_container().lookup(name)

  get_app_route: ->
    unless route = @get('application_route')
      @set 'application_route', (route = @container_lookup 'route:application')
    route

  get_app_controller: ->
    unless controller = @get('application_controller')
      @set 'application_controller', (controller = @container_lookup 'controller:application')
    controller

  get_session_timeout_controller: ->
    unless controller = @get('session_timeout_controller')
      @set 'session_timeout_controller', (controller = @container_lookup 'controller:session_timeout')
    controller

  # Invalidate Session.
  # Convience method to invalidate the session.  The application route will invalidate on errors
  # and care must be taken if use this elsewhere.
  invalidate_session: -> @get_app_route().invalidate_session()

  # Session Timeout Timer.
  reset_session_timer: (options={}) -> @get_session_timeout_controller().reset_session_timer(options)
  cancel_session_timer:             -> @get_session_timeout_controller().cancel_session_timer()

  # Message Access.
  all_messages:         -> @get('message_queue')
  all_types_visible:    -> @get('message_type_visible')
  all_message_types:    -> type for own type, value of @get('message_type')
  type_messages: (type) -> @all_messages().filterBy('type', type)

  add_message: (type, message, sticky) ->
    return if @suppress_all_messages(type)
    visible = true
    if ember.isArray(message)
      @all_messages().pushObject @message_entry(type, msg, visible, sticky) for msg in message
    else
      x = @message_entry(type, message, visible, sticky)
      @all_messages().pushObject x

  remove_message: (message) ->
    if ember.isArray(message)
      @all_messages().removeObjects message
    else
      @all_messages().removeObject message

  get_elapsed_time: (message_date) ->
    elapsed = message_date - @get('last_message_date')
    @set('last_message_date', message_date)
    elapsed

  message_entry: (type, message, visible, sticky) ->
    timestamp = null
    date      = util.current_date()
    if @get('debug_on')
      elapsed   = util.rjust(@get_elapsed_time(date),6,'0')
      timestamp = "[#{elapsed}] "
    ember.Object.create
      type:      type
      message:   message
      visible:   visible
      date:      util.date_time(date)
      timestamp: timestamp
      sticky:    sticky

  show_all_messages: ->
    @set_all_message_visibility(true)
    @set_all_type_visibility(true)
    @set_type_visibility(@message_type.all, true)

  hide_all_messages: ->
    @set_all_message_visibility(false)
    @set_all_type_visibility(false)
    @set_type_visibility(@message_type.all, false)

  toggle_visibility: (type) ->
    visible = not @all_types_visible().get(type)
    @set_type_visibility(type, visible)
    @type_messages(type).map (message) -> message.set('visible', visible)

  set_all_message_visibility: (visible) -> @all_messages().map (message) -> message.set('visible', visible)
  set_all_type_visibility:    (visible) -> @set_type_visibility(type, visible) for type in @all_message_types()
  set_type_visibility: (type, visible)  -> @all_types_visible().set(type, visible)

  # Determine messages to display.
  suppress_all_messages: (type) ->
    console.log "TYPE:", type
    return false if type == 'error'
    config.messages.suppress_all == false

  toString: -> 'totem_messages'

export default totem_messages.create()