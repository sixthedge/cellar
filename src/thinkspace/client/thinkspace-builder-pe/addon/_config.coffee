import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'pe'
    external_routes: [{login: 'users.sign_in'}, 'cases.show']

  query_params:
    assessment: ownerable: true, authable: true

  add_engines: [
    'thinkspace-message'
  ]
}
