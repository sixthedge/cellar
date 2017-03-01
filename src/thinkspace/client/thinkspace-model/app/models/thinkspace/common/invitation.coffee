import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend
  email:          ta.attr('string')
  role:           ta.attr('string')
  state:          ta.attr('string')
  expires_at:     ta.attr('date')
  accepted_at:    ta.attr('date')
  created_at:     ta.attr('date')
  invitable_type: ta.attr('string')
  invitable_id:   ta.attr('number')

  casespace_roles:
    'read': 'Student'
    'update': 'Teaching Assistant'
    'owner': 'Instructor'

  friendly_role: ember.computed 'role', -> @get('casespace_roles')[@get('role')]