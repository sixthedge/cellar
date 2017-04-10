import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'details', path: '/:assignment_id/details'
