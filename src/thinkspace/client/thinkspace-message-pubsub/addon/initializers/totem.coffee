import totem_initializer from 'totem-engines/initializer'

initializer =
  name:       'thinkspace-message'
  initialize: (app) -> totem_initializer.initialize(app)
export default initializer
