import env from './config/environment'

export default {

  env: env

  engine:
    external_routes: ['home', 'users.profile']

  add_engines: [
    'thinkspace-support-intercom'
  ]

}
