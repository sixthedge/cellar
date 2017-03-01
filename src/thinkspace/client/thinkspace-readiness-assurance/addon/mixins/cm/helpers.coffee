import ember       from 'ember'
import totem_error from 'totem/error'

export default ember.Mixin.create

  current_user_full_name: -> @rm.current_user_full_name()

  error: (args...) ->
    message = args.shift() or ''
    console.error message, args if ember.isPresent(args)
    totem_error.throw @, message

  toString: -> 'ReadinessAssuranceChatManager:' + ember.guidFor(@)
