import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'results',         path: '/results'
  @route 'admin',           path: '/admin'
  @route 'overview',        path: '/overview'
  @route 'progress_report', path: '/progress'
  @route 'reports',         path: '/reports'
  @route 'scores',          path: '/scores'
