import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  dock_is_visible: ember.computed.reads 'addons.dock_is_visible'
  dock_addons:     ember.computed.reads 'addons.dock_addons'

  ordered_addons: ember.computed 'dock_addons.[]', ->
    addons = @get('dock_addons')
    first  = []
    middle = []
    last   = []
    for addon in addons
      engine = addon.engine
      switch addon.group
        when 'first'  then first.push(addon)
        when 'middle' then middle.push(addon)
        when 'last'   then last.push(addon)
        else               middle.push(addon)
    first.concat(middle.concat(last)).reverse()
