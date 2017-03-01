import lc from 'totem-config/locales'

initializer =
  name: 'totem-config-locales'
  initialize: (instance) -> lc.process(instance)

export default initializer
