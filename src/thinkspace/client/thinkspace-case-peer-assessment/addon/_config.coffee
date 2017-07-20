import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'case-peer-assessment', path: '/cases/:assignment_id/pe'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.show', 'cases.show', 'phases.show', {pe_details: 'pe.details'},{pe_settings: 'pe.settings'}]

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-peer-assessment-results': {external_routes: {login: 'users.sign_in', cases_show: 'cases.show'}}
    'thinkspace-peer-assessment-instructor': {external_routes: {login: 'users.sign_in', pe_details: 'pe.details'}}
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
  ]
}
