import env from './config/environment'

export default {

  env: env

  engine:
    external_routes: ['home']

  add_engines: [
    'thinkspace-support-intercom'
  ]

}
