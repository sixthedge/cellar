import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'readiness_assurance', path: '/cases/:assignment_id/ra'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.index', 'spaces.show', 'cases.show', 'phases.show']

  add_engines: [
    'thinkspace-toolbar':      {external_routes: {home: 'spaces.index'}}
    'thinkspace-message'
    'thinkspace-message-pubsub'
  ]

}
