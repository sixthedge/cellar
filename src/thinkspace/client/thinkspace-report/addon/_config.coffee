import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'reports', path: '/reports'}
    external_routes: [{login: 'users.sign_in'}, 'show_report']

  ns:
    namespaces:
      report:  'thinkspace/report'
    type_to_namespace:
      'report:file':   'report'
      'report:report': 'report'

}
