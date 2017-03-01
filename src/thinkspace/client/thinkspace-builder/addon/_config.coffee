import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'builder'
    external_routes: [{login: 'users.sign_in'}, 'pe.details']

  ns:
    namespaces:
      builder: 'thinkspace/builder'

}
