import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'show',            path: '/:assignment_id'
  @route 'reports',         path: '/:assignment_id/reports'
  @route 'progress_report', path: '/:assignment_id/pr'
  @route 'scores',          path: '/:assignment_id/scores'