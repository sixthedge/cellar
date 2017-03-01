import ember from 'ember'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  setupController: (controller) ->
    controller.set 'is_route', true
