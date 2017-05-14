import env from './config/environment'

export default {

  env: env

  engine:
    mount:           'cases'
    external_routes: [
      {login: 'users.sign_in'}, 
      'spaces.show', 
      'phases.show', 
      {reports: 'reports.show'}, 
      'case-peer-assessment.overview',
      'case-readiness-assurance.overview'
    ]

  ns:
    namespaces: {casespace: 'thinkspace/casespace'}
    type_to_namespace:
      assignment:      'casespace'
      assignment_type: 'casespace'

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
    'thinkspace-resource': {dock: {routes: ['cases.show'], right_pocket: true}}
    'thinkspace-report':   {external_routes: {login: 'users.sign_in', show_report: 'reports.show'}}
    'thinkspace-peer-assessment-results': {external_routes: {login: 'users.sign_in'}}
    'thinkspace-peer-assessment-instructor': {external_routes: {login: 'users.sign_in'}}
    'thinkspace-readiness-assurance-instructor': {external_routes: {login: 'users.sign_in'}}
  ]


}
