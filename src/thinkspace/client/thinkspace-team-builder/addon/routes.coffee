import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'manage',  path: '/manage'
  @route 'edit',    path: '/edit'
  @route 'builder', path: '/builder'
  @route 'roster', path: '/roster'