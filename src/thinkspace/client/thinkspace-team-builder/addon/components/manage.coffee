import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  manager: ember.inject.service()

  on_teams: true

  is_teams:  ember.computed.equal 'on_teams', true
  is_roster: ember.computed.equal 'on_teams', false

  actions:
    toggle_view: -> @toggleProperty('on_teams'); false
