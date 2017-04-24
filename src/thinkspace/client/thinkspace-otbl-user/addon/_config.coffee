import env from './config/environment'

export default {

  env: env

  engine:
    mount: 'users'

  add_engines: ['thinkspace-message']

}
