import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''

  external_routes: ember.computed.reads 'add_engine.args.external_routes'
  services:        ember.computed.reads 'add_engine.args.services'
  has_args:        ember.computed.or 'external_routes', 'services'

  show: false

  actions:
    toggle_show: -> @toggleProperty('show'); return
