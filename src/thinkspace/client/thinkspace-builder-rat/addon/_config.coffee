import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'rat'
    external_routes: [{login: 'users.sign_in'}, 'cases.show', 'lti.setup']

  add_engines: [
    'thinkspace-message'
  ]
}
