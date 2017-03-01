import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init_base: -> 
    @init_ownerable()
    @set_all_data_loaded()

  init_ownerable: ->
    ownerable = @get('team_members').findBy 'id', @get('model.ownerable_id').toString()
    @set 'ownerable', ownerable




