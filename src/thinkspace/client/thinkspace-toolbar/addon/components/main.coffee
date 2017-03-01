import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  user_expansion_visible: false
  show_support:           false

  # TODO: 'switch_user' in session needs fixed.
  no_addon:          ember.computed.empty 'addons.active_addons'
  switch_user:       ember.computed.bool  'session.can_switch_user'
  show_switch_user:  ember.computed.and   'switch_user', 'no_addon', 'thinkspace.current_space'

  actions:

    sign_out: ->
      @set 'user_expansion_visible', false
      @totem_messages.sign_out_user()

    toggle_users:   -> @toggleProperty('user_expansion_visible'); return
    toggle_support: -> @toggleProperty('show_support'); return

  # ############################################################################
  # TEST COMPONENT LIFECYLE HOOKS
  # ############################################################################
  # didInitAttrs:      -> console.warn '.....DID INIT ATTRS', @toString()
  # didReceiveAttrs:   -> console.warn '.....DID RECEIVE ATTRS', @toString()
  # willRender:        -> console.warn '.....WILL RENDER', @toString()
  # didRender:         -> console.warn '.....DID RENDER', @toString()
  # willUpdate:        -> console.warn '.....WILL UPDATE', @toString()
  # didUpdate:         -> console.warn '.....DID UPDATE', @toString()
  # didRenderElement:  -> console.warn '.....DID RENDER ELEMENT', @toString()
  # didCreateElement:  -> console.warn '.....DID CREATE ELEMENT', @toString()
  # willInsertElement: -> console.warn '.....WILL INSERT ELEMENT', @
  # didInsertElement:  -> console.warn '+++++TOOLBAR MAIN DID INSERT ELEMENT', @toString()
