import ember from 'ember'
import base  from 'thinkspace-base/components/base'

# thinkspace-dropdown-link
# see thinkspace/common/dropdown for usage instructions

export default base.extend
  tagName: 'li'

  init_base: -> @classNames = ember.makeArray(@list_item_class)

  # didInsertElement: -> $(document).foundation()
  # didInsertElement: -> @$().foundation()

  active: ember.computed.reads 'member.active'

  select_action: ember.computed ->
    return @get('select_action_master') if @get('select_action_master')
    return @get('link.action') if @has_key(@get('link'), 'action')
    return null

  select_route: ember.computed ->
    return @get('select_route_master') if @get('select_route_master')
    return @get('link.route') if @has_key(@get('link'), 'route')
    return null

  display: ember.computed ->
    display_property = @get 'display_property_master'
    link             = @get 'link'
    if ember.isPresent(display_property)
      if typeof link['get'] == 'function'
        value = link.get(display_property)
        value = link[display_property] unless ember.isPresent(value)
      else
        value = link[display_property]
      return value
    return @get('link.display') if @has_key(@get('link'), 'display')
    return @get('link')

  route_param_key: ember.computed ->
    return @get('link').get(@get('route_param_key_master')) if @get('route_param_key_master')
    return @get("link.route_param_key") if @has_key(@get('link'), 'route_param_key')
    return @get('link')

  route_param: ember.computed 'route_param_key', ->
    @get("link.#{@get('route_param_key')}")

  has_key: (obj, key) ->
    return (key of obj) # TODO: This breaks on string arrays.

  actions:
    select: -> 
      @sendAction 'on_click' if @get('on_click')

      target = @get('action_receiver_master')
      action = @get('select_action')
      link   = @get('link')
      target.send action, link

