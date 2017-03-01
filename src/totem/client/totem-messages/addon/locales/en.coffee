export default {

  totem:
    api:
      status_codes:
        failure:               'An error occurred.'
        success:               '%@ %@ successful.'       # args = resource, action
        not_found:             '%@ could not be found.'  # args = resource
        model_validation:      '%@ validation errors.'   # args = resource
        unauthorized_access:   'You are not authorized to perform this action.'
        session_error:         'Your session had an error.'
        session_timeout:       'Your session has timed out.'
        session_expired:       'Your session has expired.'
        sign_in_error:         'Sign in error occurred.'
        default:               'Missing i18n message for handler [%@].'
        internal_server_error: 'Internal server error.'

}

