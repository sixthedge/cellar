import buildRoutes from 'ember-engines/routes'

export default buildRoutes ->
  @route 'sign_in', path: '/sign_in'
  @route 'sign_up', path: '/sign_up'

  @route 'password', path: '/password', ->
    @route 'new',          path: '/reset'
    @route 'show',         path: '/reset/:token'
    @route 'fail',         path: '/reset/fail'
    @route 'success',      path: '/reset/success'
    @route 'confirmation', path: '/reset/confirmation'

  @route 'profile', path: '/profile', ->
    @route 'payment', path: '/payment'
