import ember  from 'ember'
import {env}  from 'totem-config/config'
import util   from 'totem/util'
import ajax   from 'totem/ajax'
import config from 'totem-config/config'

export default ember.Mixin.create
  title: (tokens) ->
    name = config.stylized_platform_name
    name = env.EmberENV.PLATFORM_NAME.capitalize() unless ember.isPresent(name)
    if ember.isPresent(tokens)
      tokens = tokens.reverse()
      tokens.pushObject(name)
      tokens.join(' - ')
    else
      name

  renderTemplate: -> @render 'totem/layout'

  render_error: ->
    template = config.messages.error_template if config.messages
    template = 'totem/error' unless template
    @render template

  # If wanted to keep the 'error' page (e.g. not reload the app which is
  # simple-auth's default; clears the stores), can override this behavior
  # by implementing the below action (caution: store is not cleared):
  # 'sessionInvalidationSucceeded'
  invalidate_session: -> @get('session').invalidate()  if @get('session').get('isAuthenticated')

  actions:

    sign_out: -> @invalidate_session()

    # WARNING: Ember will auto call the 'error' action only from an error or rejected
    # promise in a route's model functions e.g. model, beforeModel, afterModel.
    # This 'error' action is fired/called:
    #   - on a 'thrown' error e.g. api module, ns.to_p.
    #   - on code errors e.g. var reference error.
    #   - via the 'RSVP on error' function if an unhandled totem error.
    #   ???- via the 'onerror' function if an unhandled totem error.
    # TODO: Is there a way to abort ajax 'in process' calls on an error?
    #       Currently they are still run without the auth token and return unauthorized (401)
    #       after the error page is displayed.
    error: (reason={}) -> @handle_error(reason)

    # authenticateSession: -> @get('session').authenticate('authenticator:totem')

    hide_all:   (type) -> @totem_messages.hide_all()
    hide_type:  (type) -> @totem_messages.hide_type(type)
    show_all:   (type) -> @totem_messages.show_all()
    show_type:  (type) -> @totem_messages.show_type(type)
    clear_type: (type) -> @totem_messages.clear_type(type)
    clear_all: ->
      @totem_messages.clear_all()
      @reset_totem_error_template_messages()

    show_totem_message_outlet: (template_name, options={}) ->
      @_show_totem_message_outlet(options)
      @render template_name,
        into:       'totem/layout'
        outlet:     'totem_message_outlet'
        controller: options.controller
        model:      options.model

    hide_totem_message_outlet: ->
      @_hide_totem_message_outlet()
      @disconnectOutlet
        outlet:     'totem_messages_outlet'
        parentView: 'totem/layout'

  handle_error: (reason={}) ->
    util.console_info '1.......action-error', reason
    @invalidate_session()
    if util.is_promise(reason)
      result = reason._result
      reason = result if util.is_hash(result) and result.is_totem_error
    return if reason.is_totem_error and reason.is_handled
    reason.is_handled = true  if reason.is_totem_error
    if reason.is_totem_error and reason.is_api_error
      util.console_error @, reason if util.is_development()
    else
      @totem_messages.error reason.message
      util.console_error @, reason if util.is_development()
    @render_error()
    return

  reset_totem_error_template_messages: ->
    @set_totem_error_template_message(null)

  set_totem_error_template_message: (message) ->
    @get('controller').set('totem_error_template_message', message)

  _show_totem_message_outlet: (options) ->
    message_outlet = @jquery_totem_message_outlet()
    main_outlet    = @jquery_totem_main_outlet()
    message_outlet.removeClass('totem_message_outlet-hide')
    main_outlet.addClass('totem_main_outlet-fade')  unless options.fade_main_outlet == false
    # Add custom class names to outlets
    class_names = @_class_names(options.outlet_class_names)
    @set 'controller.totem_message_outlet_class_names', class_names
    message_outlet.addClass(class_names)  if class_names
    class_names = @_class_names(options.main_outlet_class_names)
    @set 'controller.totem_main_outlet_class_names', class_names
    main_outlet.addClass(class_names)  if class_names

  _hide_totem_message_outlet: ->
    message_outlet = @jquery_totem_message_outlet()
    main_outlet    = @jquery_totem_main_outlet()
    message_outlet.addClass('totem_message_outlet-hide')
    main_outlet.removeClass('totem_main_outlet-fade')
    # Remove custom class names from outlets
    class_names = @get 'controller.totem_message_outlet_class_names'
    message_outlet.removeClass(class_names)  if class_names
    class_names = @get 'controller.totem_main_outlet_class_names'
    main_outlet.removeClass(class_names)  if class_names

  _class_names: (class_names) ->
    return null unless class_names
    ember.makeArray(class_names).compact().join(' ')

  jquery_totem_message_outlet: -> ember.$('.totem_message_outlet')
  jquery_totem_main_outlet:    -> ember.$('.totem_main_outlet')
