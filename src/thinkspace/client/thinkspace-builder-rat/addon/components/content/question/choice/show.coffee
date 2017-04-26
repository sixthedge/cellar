import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # choice/show.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  
  ## Model is ember object wrapping raw choice json
  model: null

  alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  init_base: ->
    @init_prefix(@get('index'))

  init_prefix: (i) ->
    prefix = i%26
    prefix = @get('alphabet')[prefix]
    suffix = Math.floor(i/26)
    if suffix == 0 then suffix = ''
    result = prefix + suffix
    @set('prefix', result)

