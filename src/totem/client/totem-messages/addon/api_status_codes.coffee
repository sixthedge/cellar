# The status_code definition properties: 
#     codes:    (required) [number, number, ...] array of status codes to match the definition
#     queue:    (optional) info|warn|error|debug message queue (default is no message)
#     fatal:    (optional) true|false|string (default: false) whether the error is fatal
#:              #=> A non-empty string is fatal and string will be included in the fatal message.
#     with_key: (optional) true|false (default: false) when true for model validations prefixes message with 'key: '
#
class ApiStatusCodes

  @status_code_definitions:

    not_found:
      codes: [404]
      queue: 'error'
      i18n:  ['resource']
      fatal: true

    model_validation:
      codes:       [422]
      queue:       'warn'
      i18n:        ['resource']
      fatal:       false

    unauthorized_access:
      codes:              [423]
      queue:              'error'
      fatal:              false
      hide_loading:       true
      model_rollback:     true
      allow_user_message: true
      allow_callback:     true

    internal_server_error:
      codes:         [500]
      queue:         'error'
      error_message: 'Internal server error'
      fatal:         true

    session_error:
      codes: [511]
      queue: 'error'
      fatal: false
      match_response_text: 
        timeout: 'session_timeout'
        expired: 'session_expired'

    sign_in_error:
      queue: 'error'
      fatal: false

    success:
      allow_user_message: false
      queue:              'info'
      i18n:               ['resource', 'action']
      fatal:              false

    failure:
      queue: 'error'
      fatal: true

  # Public methods to get values from this class.
  # These methods should be used rather than accessing the values directly so
  # future changes will not impact code.
  @definition: (code) ->
    return null unless code
    code_def = null
    for handler, values of @status_code_definitions
      if code == handler
        code_def         = values
        code_def.handler = handler
      else
        codes = values.codes or []
        if (code in codes)
          code_def         = values
          code_def.handler = handler
      break  if code_def
    code_def

export default ApiStatusCodes
