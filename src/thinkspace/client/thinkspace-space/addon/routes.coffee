import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'show',   path: '/:space_id' 
  @route 'new', path: '/new'
  @route 'roster', path: '/:space_id/roster', ->
    @route 'import', path: '/import'
    @route 'invite', path: '/invite'