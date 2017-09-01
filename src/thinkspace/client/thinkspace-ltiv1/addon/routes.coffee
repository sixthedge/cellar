import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'sign_in',        path: '/sign_in'
  @route 'setup',          path: '/setup'
  @route 'nag',            path: '/error'