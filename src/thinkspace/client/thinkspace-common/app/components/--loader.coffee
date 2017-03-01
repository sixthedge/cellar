import ember from 'ember'
import ns    from 'totem/ns'
import i18n  from 'totem/i18n'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName:   ''
  type:      'default'
  size:      'medium'
  header:    ''
  message:   ''
  i18n_path: ''

  text: ember.computed 'message', 'i18n_path', ->
    message   = @get 'message'
    i18n_path = @get 'i18n_path'
    return i18n.message path: i18n_path if ember.isPresent(i18n_path)
    return 'Loading...' unless ember.isPresent(message)
    return message

  # c_loader: ember.computed 'type', -> ns.to_p('common', 'shared', 'loader', @get('type'))
  c_loader: ember.computed 'type', -> "__loader/#{@get('type')}"
