import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'lti'
    external_routes: [{login: 'users.sign_in'}, 'spaces.show', 'cases.show', 'spaces.new']

  add_engines: ['thinkspace-message']
}
