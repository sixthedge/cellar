import ember      from 'ember'
import ta         from 'totem/ds/associations'
import data_mixin from 'totem/mixins/data'

export default ta.Model.extend data_mixin, ta.add(
    ta.polymorphic 'ownerable'
    ta.belongs_to  'list',              reads: {}
    ta.has_many    'observation_notes', reads: {}
  ),

  position:       ta.attr 'number'
  value:          ta.attr 'string'
  created_at:     ta.attr 'date'
  list_id:        ta.attr 'number'   # used in combining list observations
  ownerable_id:   ta.attr 'number'   # used in filter
  ownerable_type: ta.attr 'string'   # used in filter

  # ### Totem Data
  totem_data_config: ability: true

  # didCreate: -> @didLoad()
  #
  # didLoad: ->
  #   # Using list_id here instead of the relationship due to some issues with the seriazlizer options on a path viewer.
  #   # => It would return a null list even though the ID was present.
  #   @tc.find_record(ta.to_p('list'), @get('list_id')).then (list) =>
  #     list.get(ta.to_p('observations')).then (observations) =>
  #       observations.pushObject(@) unless observations.includes(@)

  notes_count:  ember.computed.reads ta.to_prop('observation_notes', 'length')
  has_no_notes: ember.computed.lte   'notes_count', 0
  has_notes:    ember.computed.gt    'notes_count', 0

  category_icon: ember.computed.reads 'list.category_icon'

  is_used: null
  get_is_used:              -> @get 'is_used'
  set_is_used: (value=true) -> @set 'is_used', value  unless @get_is_used() == value
