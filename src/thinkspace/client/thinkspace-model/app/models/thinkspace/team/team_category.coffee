import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend

  title:         ta.attr('string')
  category:      ta.attr('string')

  is_peer_review:   ember.computed.equal 'category', 'peer_review'
  is_collaboration: ember.computed.equal 'category', 'collaboration'
