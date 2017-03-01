import ember from 'ember'
import totem_error    from 'totem/error'
import totem_messages from 'totem-messages/messages'

initializer =
  name:       'totem-application-errors'
  after:      ['totem', 'totem-messages']
  initialize: (instance) ->

    # RSVP errors can be raised by normal events (e.g. any transition aborted)
    # and these errors are not be fatal.  Only if the error was thrown
    # by 'totem_error' should they be handled.
    ember.RSVP.on 'error', (reason=null) ->
      console.info '2.......rsvp-error', reason
      if reason and reason.is_totem_error
        if not reason.is_handled
          route = instance.lookup('route:application')
          route.handle_error(reason) if route and route.handle_error

    # Ember will call this function on errors.
    # Some errors should not be fatal such as rails model validation errors and ember-validation errors.
    # Totem should handle fatal errors by displaying an error page, so overriding the default functionality.
    # NOTE: ActiveModelAdapter throws an 'InvalidError' on model validation errors.
    #       These are handled by the messages:api module and are not fatal errors,
    #       However, this function is the first in the error-chain for them.
    ember.onerror = (reason=null) ->
      console.info '3.......on-error', reason
      message = reason and reason.message
      console.error message  if message
      # return if reason and reason.status == 422   # ignore model validations
      # return if reason and reason.is_totem_error and reason.is_handled
      # route = instance.lookup('route:application')
      # route.send 'error', reason

export default initializer
