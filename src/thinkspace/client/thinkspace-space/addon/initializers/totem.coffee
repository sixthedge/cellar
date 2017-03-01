import totem_initializer from 'totem-engines/initializer'

initializer =
  name:       'thinkspace-space'
  initialize: (app) -> totem_initializer.initialize(app)
export default initializer
