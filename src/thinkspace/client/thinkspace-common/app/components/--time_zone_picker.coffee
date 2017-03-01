import ember          from 'ember'
import ns             from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  ttz: ember.inject.service()

  # ### Properties

  selected_zone: null

  # ### Computed Properties
  zones: ember.computed.reads 'ttz.zones'

  # ### Components
  c_dropdown: ns.to_p 'common', 'dropdown'

  # ### Events
  init_base: ->
    @set_zone()
    @set_selected_zone()

  set_zone: ->
    zone = @get 'zone'
    return if ember.isPresent(zone)
    @set 'zone', @get('ttz').get_client_zone_iana()

  set_selected_zone: ->
    zone          = @get 'zone' # IANA
    selected_zone = @get('ttz').find_by_zone_property 'iana', zone
    @set 'selected_zone', selected_zone

  actions:
    select: (zone) -> 
      @set 'selected_zone', zone
      @sendAction 'select', zone.iana
