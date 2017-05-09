import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'readiness-assurance', path: '/cases/:assignment_id/rat/admin'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.index', 'spaces.show', 'cases.show', 'phases.show', 'case-readiness-assurance.overview']

  add_engines: [
    'thinkspace-toolbar':      {external_routes: {home: 'spaces.index'}}
    'thinkspace-message'
    'thinkspace-message-pubsub'
  ]

}
