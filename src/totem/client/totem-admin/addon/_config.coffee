import env from './config/environment'

export default {

  env: env

  engine:
    mount:           'admin'
    services:        ['store', 'session', 'pubsub', 'ttz', 'i18n']
    external_routes: [{login: 'users.sign_in'}, ]

}
