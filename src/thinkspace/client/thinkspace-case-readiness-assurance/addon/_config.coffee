import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'case-readiness-assurance', path: '/cases/:assignment_id/rat'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.show', 'cases.show', 'phases.show', 'readiness-assurance.progress_report', {rat_details: 'rat.details'},{rat_settings: 'rat.settings'}]

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index', 'users.profile'}}
  ]
}
