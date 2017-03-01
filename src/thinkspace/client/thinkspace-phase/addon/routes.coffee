import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'show', path: '/:phase_id'
