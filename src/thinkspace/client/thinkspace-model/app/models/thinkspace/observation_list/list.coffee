import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.has_many    'lists', inverse: ta.to_p('lists')
    ta.has_many    'observations', reads: {from: 'lists', filter: true, sort: 'position:asc'}
    ta.has_many    'observation_list:groups', reads: {name: 'groups'}
  ),

  category:      ta.attr()
  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')

  observation_positions:    ember.computed.mapBy 'observations', 'position'
  max_observation_position: ember.computed.max('observation_positions')

  category_id: ember.computed -> (@get('category.name') or '').toLowerCase()

  category_icon: ember.computed ->
    switch @get('category_id')
      when 'd'
        icon = '<i class="fa fa-flask data" title="Data"></i>'
      when 'h'
        icon = '<i class="im im-book history" title="History"></i>'
      when 'm'
        icon = '<i class="fa fa-circle-o mechanism" title="Mechanism"></i>'
      else
        icon = '<i class="fa fa-square unknown" title="Unknown"></i>'
    icon.htmlSafe()

  category_values: [
    {id: 'd', label: 'Data'}
    {id: 'h', label: 'History'}
  ]

  edit_component: ta.to_p 'list', 'edit'
