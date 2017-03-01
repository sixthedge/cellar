import ember from 'ember'

# Implement the socket.io-client callback function.
# A new instance of this class will be the 'single' callback function for an event (e.g. on 'event').

# Pubsub tracks the callbacks by socket->event->source->[callback-method-string(s)].
# An instance of this class will call the pubsub service (since pubsub is never destroyed)
# to initiate the callback(s).
# The pubsub service will only call a callback if the source is not destroyed.

class PubSubCallback

  constructor: (@pubsub, @socket, @event) -> return

  fn: (args...) =>
    args.push(@event)
    @pubsub.call_event_callback(@socket, @event, args)

  toString: -> 'PubSubCallback'

export default PubSubCallback
