import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  init_base: ->
    model = @get 'model'
    model.get(ns.to_p('assignments')).then (assignments) =>
      @set_all_data_loaded()
