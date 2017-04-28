import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  resetController: (controller, isExiting) ->
    if isExiting
      qp = controller.get('queryParams')
      qp.forEach (p) =>
        controller.set('p', null)
