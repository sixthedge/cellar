import ember             from 'ember'
import ns                from 'totem/ns'
import util              from 'totem/util'
import ajax              from 'totem/ajax'
import totem_scope       from 'totem/scope'
import totem_messages    from 'totem-messages/messages'
import phase_manager_map from './map/base'

export default ember.Mixin.create

  addons:        ember.inject.service()
  tvo:           ember.inject.service()
  server_events: ember.inject.service()

  map: null

  is_current_html: '<i class="tsi tsi-left tsi-tiny tsi-right-arrow left">'

  is_view_only: ember.computed.reads 'totem_scope.is_view_only'  # template helper

  regenerate_observer: ember.observer 'tvo.regenerate_view', -> @generate_view()

  current_phase_show_component: null

  init: ->
    @_super(arguments...)
    @thinkspace     = @get('thinkspace')
    @tvo            = @get('tvo')
    @addons         = @get('addons')
    @ns             = ns
    @ajax           = ajax
    @util           = util
    @totem_scope    = totem_scope
    @totem_messages = totem_messages
    @set_map()

  reset: ->
    @clear_current_phase_show_component()
    @addons.reset_addons()
    @totem_scope.ownerable_to_current_user()

  set_map: ->
    @pmap = @map = phase_manager_map.create
      thinkspace:     @thinkspace
      ns:             @ns
      util:           @util
      ajax:           @ajax
      tc:             @tc
      totem_scope:    @totem_scope
      totem_messages: @totem_messages
      pm:             @

  # The current phase show component is saved in the phase manager so the
  # phase manager can toggle the template show and force a new phase layout
  # component to be created (otherwise the page is not updated with the new compiled layout).
  clear_current_phase_show_component:      -> @set_current_phase_show_component(null)
  get_current_phase_show_component:        -> @get 'current_phase_show_component'
  set_current_phase_show_component: (comp) -> @set 'current_phase_show_component', comp

  get_assignment: -> @thinkspace.get_current_assignment()
  get_phase:      -> @thinkspace.get_current_phase()

  show_loading_outlet: -> @totem_messages.show_loading_outlet()
  hide_loading_outlet: -> @totem_messages.hide_loading_outlet()

  set_view_only_on:  -> @totem_scope.view_only_on()
  set_view_only_off: -> @totem_scope.view_only_off()

  toString: -> 'PhaseManager'
