import ember from 'ember'

export default ember.Mixin.create

  message:  null
  messages: null

  init_values: ->
    @set 'message', null
    @set 'messages', @format_messages()

  add_message: ->
    message = @get('message')
    if message
      @rm.save_chat(@qid, message).then => return

  format_messages: ->
    messages = @get(@chat_path) or []
    (@format_message(hash) for hash in messages)

  format_message: (hash) ->
    message = hash.message
    name    = "#{hash.first_name} #{hash.last_name}"
    stime   = hash.time
    time    = @rm.ttz.format(stime, format: 'MMM Do, h:mm a')
    {time, name, message}

  handle_chat: (message) ->
    messages = @get(@chat_path)
    if messages
      messages.push(message)
    else
      @set @chat_path, [message]
    @set 'message', null
    @get('messages').pushObject @format_message(message)
