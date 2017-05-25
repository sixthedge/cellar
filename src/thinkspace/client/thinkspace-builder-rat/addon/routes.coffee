import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'details',      path: '/:assignment_id/details'
  @route 'content',      path: '/:assignment_id/content'
  @route 'settings',     path: '/:assignment_id/settings'
  @route 'confirmation', path: '/:assignment_id/confirmation'
