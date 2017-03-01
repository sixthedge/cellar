import ember from 'ember'
import base  from 'thinkspace-base/controllers/base'

export default base.extend
  queryParams:    ['query_id', 'phase_settings']
  query_id:       null
  phase_settings: null

  phase_settings_obj: ember.computed 'phase_settings', ->
    phase_settings = @get 'phase_settings'
    return unless ember.isPresent(phase_settings)
    string = decodeURIComponent(phase_settings)
    return unless ember.isPresent(string)
    JSON.parse(string)

  thinkspace: ember.inject.service()

  set_phase_settings:   (obj) -> @set 'phase_settings', encodeURIComponent(JSON.stringify(obj))
  reset_phase_settings: -> @set 'phase_settings', null
  reset_query_id: -> @set 'query_id', null

  init: ->
    @_super()
    @get('thinkspace').set_phases_show_controller(@)

  actions:
    submit_phase: -> @send('submit')
