import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'users'
    external_routes: [
      {login: 'users.sign_in'},
      'spaces.index'
    ]

  add_engines: [
    'thinkspace-message'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index'}}
  ]

}
