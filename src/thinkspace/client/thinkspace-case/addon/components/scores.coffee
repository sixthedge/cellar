import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  init_base: ->
    @get('model').get(ns.to_p('assignment_type')).then (assignment_type) =>
      @set('assignment_type', assignment_type)
