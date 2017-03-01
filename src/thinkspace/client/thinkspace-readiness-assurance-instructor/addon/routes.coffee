import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'dashboard',  path: '/dashboard'

  @route 'progress_report', path: '/progress', ->
    @route 'irat', path: '/irat'
    @route 'trat', path: '/trat'