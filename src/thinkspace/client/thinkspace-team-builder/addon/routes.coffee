import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'teams', path: '/teams', ->
    @route 'manage',  path: '/manage'
    @route 'edit',    path: '/edit'
    @route 'builder', path: '/builder'
    @route 'roster', path: '/roster'