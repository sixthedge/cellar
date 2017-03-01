import ts from 'totem/scope'
import tc from 'totem/cache'
import ax from 'totem/ajax'

initializer =
  name: 'totem'
  initialize: (instance) ->

    # Set the instance (was called container) in some modules.
    ts.set_instance(instance)   # totem scope
    tc.set_instance(instance)   # totem cache
    ax.set_instance(instance)   # totem ajax

export default initializer
