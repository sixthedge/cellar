import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'thinkspace-team-builder', path: '/spaces/:space_id/teams'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.show', 'spaces.roster', 'builder.new']

  ns:
    namespaces: {team_builder: 'thinkspace-team-builder'}

  add_engines: [
    'thinkspace-message'
    'thinkspace-message-pubsub'
    'thinkspace-dock'
    'thinkspace-toolbar':  {external_routes: {home: 'spaces.index', 'users.profile'}}
  ]


}
