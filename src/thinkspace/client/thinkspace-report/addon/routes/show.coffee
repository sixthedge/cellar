import ember from 'ember'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  setupController: (controller, params) ->
    controller.set 'token', params.token
