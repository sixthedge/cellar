import ember from 'ember'
import {module_prefix} from 'totem-config/config'

export default ember.Mixin.create

  app_path: (path) -> "#{module_prefix}/#{path}"

  require_module: (path) ->
    mod = null
    try
      mod = require path
    catch e
    finally
      return (mod and mod.default)
