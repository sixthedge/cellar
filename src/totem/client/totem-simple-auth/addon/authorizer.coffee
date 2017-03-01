import ember from 'ember'
import base  from 'ember-simple-auth/authorizers/devise'

# Extend the devise authorizer in case need to modify some behavior.
# Can switch authorizer by extending a different one or implementing a custom one.

export default base.extend()

  # Example:
  # authorize: (jqXHR, requestOptions) ->
  #   Do something here and call super if appropriate
  #   @_super(jqXHR, requestOptions)
