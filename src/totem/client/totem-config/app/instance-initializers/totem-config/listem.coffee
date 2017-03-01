import lm from 'totem-config/listem'

initializer =
  name: 'totem-config-listem'
  initialize: (instance) -> lm.process()

export default initializer
