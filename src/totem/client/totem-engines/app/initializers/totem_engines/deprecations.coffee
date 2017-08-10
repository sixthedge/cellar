# Register a deprecation handler to suppress deprecation messages.

initializer =
  name:       'totem-engines-deprecations'
  initialize: (app) ->
    EmberENV.LOG_STACKTRACE_ON_DEPRECATION = false
    # return  # ### show-all ### #=> do not register a deprecation handler e.g. no suppression, see all messages ### #
    Ember.Debug.registerDeprecationHandler (message, options, next) ->
      return # ### show-none ### #=> do not display any messages ### #
      # ### show-match ### #=> show messages that match the message text e.g. call 'next' the standard ember hander). ### #
      switch
        # when message.match(/includes/)                   then next('>>INCLUDES<<: ' + message, options)  # array.contains s/b array.includes
        when message.match(/twice in a single render/)   then next('>>TWICE<<: ' + message, options)
        # when message.match(/underscore/)                 then next('>>UNDERSCORE<<: ' + message, options)

export default initializer