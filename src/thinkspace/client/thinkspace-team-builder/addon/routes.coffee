import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'roster',  path: '/roster'
  @route 'manage',  path: '/manage'
  @route 'edit',    path: '/:team_id/edit'
  @route 'builder', path: '/builder'