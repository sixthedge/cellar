import ember from 'ember'
import ds from 'ember-data'
import ta from 'totem/ds/associations'
import m_format from 'totem-messages/mixins/messages/format'

export default ember.Mixin.create m_format,
  date:       ta.attr('date')
  state:      ta.attr('string')
  time:       ta.attr('string')
  to:         ta.attr('string')
  from:       ta.attr('string')
  body:       ta.attr('string')
  source:     ta.attr('string')
  rooms:      ta.attr()
  to_users:   ta.attr()
  to_teams:   ta.attr()
  from_users: ta.attr()
  from_teams: ta.attr()

  is_new:      ember.computed.equal 'state', 'new'
  is_previous: ember.computed.equal 'state', 'previous'
  is_inactive: ember.computed.equal 'state', 'inactive'

  save_message: null  # override in model if appropriate ('true'=message will be auto-saved, 'function'=called to save message)

  pre_message: ember.computed -> @format_pre(@)

  set_new:      -> @set 'state', 'new'
  set_previous: -> @set 'state', 'previous'
  set_inactive: -> @set 'state', 'inactive'
