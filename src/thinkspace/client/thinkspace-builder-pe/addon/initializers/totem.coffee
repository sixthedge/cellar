import totem_initializer from 'totem-engines/initializer'

###
# # totem.coffee
- Type: **Initializer**
- Package: **ethinkspace-builder-pe**
###
initializer =
  name:       'thinkspace-builder-pe'
  initialize: (app) -> totem_initializer.initialize(app)
export default initializer
