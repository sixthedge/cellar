import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'overview',        path: '/overview'
  @route 'scores',          path: '/scores'
