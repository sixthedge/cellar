import ember from 'ember'
import ajax  from 'totem/ajax'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  load: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(@message_model_type)
      verb   = 'post'
      url    = @get('message_load_url')
      query  = {url, verb}
      totem_scope.add_auth_to_ajax_query(query)
      query.data.load_messages = @get_load_data(options)
      ajax.object(query).then (payload) =>
        return resolve() if ember.isBlank(payload)
        messages = payload.data
        return resolve() if ember.isBlank(messages)
        messages.forEach (msg) =>
          data  = msg.attributes or {}
          value = data.value or {}
          delete (data.value)
          ember.merge data, value
          data.state = 'previous'
          @add(data)
        resolve()

  get_load_data: (options) ->
    data           = {}
    data.from_time = options.from_time
    data.to_time   = options.to_time
    data.rooms     = options.room or options.rooms
    data
