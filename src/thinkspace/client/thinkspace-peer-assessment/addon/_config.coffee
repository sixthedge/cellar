import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'thinkspace-peer-assessment', path: '/cases/:assignment_id/pe'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.show', 'cases.show', 'phases.show']

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-peer-assessment-results': {external_routes: {login: 'users.sign_in'}}
    'thinkspace-peer-assessment-instructor': {external_routes: {login: 'users.sign_in'}}
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
  ]
}
