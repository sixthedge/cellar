import ember from 'ember'

platform_name = ember.ENV.PLATFORM_NAME or ''
env_mod       = require(platform_name + '/config/environment')
env           = (env_mod or {}).default or {}
config        = env.totem || {}
module_prefix = env.modulePrefix || ''
mp            = module_prefix + '/'
export {module_prefix}
export {mp}
export {env}
export default config
