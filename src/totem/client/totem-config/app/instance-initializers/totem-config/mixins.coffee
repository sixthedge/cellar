import tcm from 'totem-config/mixins'

initializer =
  name: 'totem-config-mixins'
  initialize: (instance) -> tcm.process()

export default initializer
