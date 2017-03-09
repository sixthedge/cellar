import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'roster',  path: '/roster'
  @route 'manage',  path: '/manage'
  @route 'edit',    path: '/edit'
  @route 'builder', path: '/builder'