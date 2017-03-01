import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'pe-results'}
    external_routes: [{login: 'users.sign_in'}]

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
  ]
}
