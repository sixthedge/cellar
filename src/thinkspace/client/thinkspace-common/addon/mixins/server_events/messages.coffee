import ember from 'ember'

export default ember.Mixin.create

  messages_loaded: false

  load_messages: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @messages_loaded
      options.room ?= @assignment_current_user_room()
      @messages.load(options).then =>
        @messages_loaded = true
        resolve()
