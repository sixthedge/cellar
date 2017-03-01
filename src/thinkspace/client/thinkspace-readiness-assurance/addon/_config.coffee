import env from './config/environment'

export default {

  env: env

  ns:
    namespaces:
      readiness_assurance: 'thinkspace/readiness_assurance'
    type_to_namespace:
      'ra':              'readiness_assurance'
      'ra:assessment':   'readiness_assurance'
      'ra:response':     'readiness_assurance'
      'ra:chat':         'readiness_assurance'
      'ra:status':       'readiness_assurance'
      'ra:server_event': 'readiness_assurance'
      'ra:admin':        'readiness_assurance'
  
  query_params:
    'ra:assessment':    ownerable: true, authable: true
    'ra:response':      ownerable: true, authable: true
    'ra:chat':          ownerable: true, authable: true
    'ra:status':        ownerable: true, authable: true
    'ra:server_event':  ownerable: true, authable: true

  add_engines: [
    'thinkspace-readiness-assurance-irat'
    'thinkspace-readiness-assurance-trat'
    'thinkspace-message-pubsub'
  ]

}
