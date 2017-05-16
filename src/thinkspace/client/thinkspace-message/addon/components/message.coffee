import ember from 'ember'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend

  # ### Properties
  auto_clear_after: 5000
  dismiss_after:    250
  dismissed:        false

  image_class_prefix:   'ts-message_image-'
  info_image_suffixes:  ['info-1']
  error_image_suffixes: ['error-1']

  info_headers:  ['Success', 'Hooray!', 'Woohoo']
  error_headers: ['Uh Oh', 'Whoops', "D'oh"]
  message_classes: {
    'info':    'totem-message--success',
    'success': 'totem-message--success',
    'error':   'totem-message--error'
  }

  message_class: ember.computed 'model.type', -> @get('message_classes')[@get('model.type')]

  # ### Computed properties
  is_debug:    ember.computed.bool 'totem_messages.debug_on'
  # all messages must auto clear otherwise they may never appear since the queue only shows the first message
  auto_clear:  true#ember.computed.not  'model.sticky'
  image_class: ember.computed 'model.type', -> @get_image_class_for_type()
  type_header: ember.computed 'model.type', -> @get_header_for_type()

  # ### Events
  didInsertElement: -> 
    @add_clear_timer() if @get('auto_clear')

  # ### Clearing helpers
  click: ->
    @set 'dismissed', true
    ember.run.cancel(@timer)  if @timer
    @clear_message()

  add_clear_timer: ->  @timer = ember.run.later(@, 'clear_message', @get('auto_clear_after'))

  clear_message: ->
    return if util.is_destroyed(@)
    ms = @get 'dismiss_after'
    @$().fadeOut(ms)
    ember.run.later(@, 'remove_message', ms)

  remove_message: -> @sendAction 'remove', @get('model')

  # ### Image helpers
  get_default_image_class: ->
    prefix = @get 'image_class_prefix'
    prefix + 'default'

  get_image_class_for_type: ->
    type     = @get 'model.type'
    suffixes = @get "#{type}_image_suffixes"
    return @get_default_image_class() unless ember.isPresent(suffixes)
    suffix = suffixes[Math.floor(Math.random() * suffixes.length)]
    prefix = @get 'image_class_prefix'
    prefix + suffix

  # ### Header helpers
  get_header_for_type: ->
    type    = @get 'model.type'
    headers = @get "#{type}_headers"
    return '' unless ember.isPresent(headers)
    headers[Math.floor(Math.random() * headers.length)]
