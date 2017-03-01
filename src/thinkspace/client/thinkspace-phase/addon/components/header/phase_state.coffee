import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  init_base: ->
    @model.get(ns.to_p 'phase').then (@phase) =>
      @model.get('ownerable').then (ownerable) =>
        @is_selected = (@phase == @get('thinkspace').get_current_phase()) if @model.is_mock
        @title       = @phase.get('title') + ' - ' + ownerable.get('full_name')
        @set_all_data_loaded()
