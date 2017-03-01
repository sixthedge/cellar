import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_menu from 'thinkspace-readiness-assurance-instructor/mixins/menu'

export default base.extend m_menu,

  menu: ember.computed.reads 'admin.dashboard_menu'

  model_route: ember.computed ->
    model = @get('model')
    route = @totem_scope.get_record_path(model).pluralize()
    route = route.split('/').get('lastObject')
    route = 'cases' if route == 'assignments'
    "#{route}.show"

  willDestroy: -> @am.reset()

  init_menu: ->
    @am.set_model @get('model')
    room = @se.get_admin_room()
    @se.messages.load({room})

  # # ### TESTING ONLY - auto-select
  # didInsertElement: ->
    # @select_action @find_config(@am.c_menu_messages)
    # @select_action @find_config(@am.c_menu_irat)
    # @select_action @find_config(@am.c_menu_timers)
    # @select_action @find_config(@am.c_timers_active)
  # # ### TESTING ONLY
