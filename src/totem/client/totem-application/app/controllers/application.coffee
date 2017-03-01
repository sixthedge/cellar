import ember from 'ember'

export default ember.Controller.extend

  # Message can be stylized in the template totem/ember/error.
  # Add more messages as required (with a corresponding template change).
  totem_error_template_message: null

  # Messages for the totem outlet as an array of objects with the message
  # in 'object.message'.
  totem_outlet_messages: null
  has_messages:          ember.computed.gt 'totem_outlet_messages.length', 0

  # Custom outlet class names
  totem_main_outlet_class_names:    null
  totem_message_outlet_class_names: null

  # Show the totem outlet in the application layout.
  # Messages can be contained in the options key 'outlet_messages' or
  # obtained from the totem_messages queue by passing a 'message_type'.
  totem_message_outlet: (options={}) ->
    template_name = options.template_name or 'totem_message_outlet/messages'
    controller    = options.outlet_controller
    model         = options.outlet_model
    messages      = options.outlet_messages
    message_type  = options.message_type
    message_prop  = 'totem_outlet_messages'

    if messages
      messages = @get_formatted_outlet_messages(messages)
    else
      messages = @get_totem_messages_for_type(message_type)

    if controller
      @set message_prop, null
      controller.set message_prop, messages
    else
      @set message_prop, messages

    @send 'show_totem_message_outlet', template_name,
      controller:              controller   # controller instance or lookup
      model:                   model
      outlet_class_names:      options.outlet_class_names
      main_outlet_class_names: options.main_outlet_class_names
      fade_main_outlet:        options.fade_main_outlet

  get_totem_messages_for_type: (type) ->
    return [] unless type
    @totem_messages.type_messages(type)

  get_formatted_outlet_messages: (messages) ->
    return [] unless messages
    messages           = ember.makeArray(messages).compact()
    formatted_messages = []
    for message in messages
      if typeof(message) == 'string'
        formatted_messages.push {message: message}
      else
        formatted_messages.push message
    formatted_messages
