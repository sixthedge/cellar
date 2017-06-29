import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  model: null

  init_base: ->
    @set_loading 'link'
    model = @get('model')
    model.get('assignment_type').then (assignment_type) =>
      if assignment_type.get('is_pe')
        link = 'pe_details'
      else
        link = 'rat_details'
      @set 'link', link
      @reset_loading 'link'
