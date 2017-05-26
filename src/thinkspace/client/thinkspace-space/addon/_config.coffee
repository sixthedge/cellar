import env from './config/environment'

export default {

  env: env

  engine:
    mount:           'spaces'
    external_routes: [{login: 'users.sign_in'}, 'cases.show', 'builder.new', 'thinkspace-team-builder.teams.manage']

  add_engines: [
    'thinkspace-message'
    'thinkspace-dock'
    'thinkspace-toolbar': {external_routes: {home: 'spaces.index'}}
  ]

}
