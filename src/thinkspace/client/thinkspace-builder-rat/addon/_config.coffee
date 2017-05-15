import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'rat'
    external_routes: [{login: 'users.sign_in'}, 'cases.show']

  add_engines: [
    'thinkspace-message'
  ]
}
