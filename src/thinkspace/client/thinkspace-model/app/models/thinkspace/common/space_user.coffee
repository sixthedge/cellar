import ember  from 'ember'
import config from 'totem-config/config'
import ta     from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'user', reads: {}
    ta.belongs_to 'space', reads: {}
  ), 

  role:     ta.attr('string')
  space_id: ta.attr('number')
  state:    ta.attr('string')

  friendly_roles: ember.computed ->
    roles_map = config.roles_map
    console.error "Could not find roles map in config, cannot process space_user." unless ember.isPresent(roles_map)
    roles = []
    roles.push(friendly) for role, friendly of roles_map
    roles

  friendly_role: ember.computed 'role', ->
    current_role = @get 'role'
    roles_map    = config.roles_map
    name         = null
    console.error "Could not find roles map in config, cannot process space_user." unless ember.isPresent(roles_map)
    for role, friendly of roles_map
      name = friendly if ember.isEqual(role.toLowerCase(), current_role.toLowerCase())
    console.error "Could not find friendly for [#{current_role}] in config.roles_map [#{roles_map}]." unless ember.isPresent(name)
    name

  friendly_state: ember.computed 'state', ->
    state = @get('state')
    switch state
      when 'active'
        'Active'
      when 'inactive'
        'Dropped'
      else
        'N/A'

  is_active:   ember.computed.equal 'state', 'active'
  is_inactive: ember.computed.equal 'state', 'inactive'

  set_role_from_friendly: (friendly_role) ->
    roles = config.roles_map
    for role, friendly of roles
      @set 'role', role if friendly == friendly_role
