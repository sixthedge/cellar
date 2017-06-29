import env from './config/environment'

export default {

  env: env

  engine:
    mount:           'peer-assessment-instructor'
    external_routes: [{login: 'users.sign_in'}, {pe_details: 'pe.details'}]

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
  ]
}
