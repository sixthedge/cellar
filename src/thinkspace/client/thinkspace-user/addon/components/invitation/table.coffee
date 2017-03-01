import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName:          'table'
  c_invitation_row: ns.to_p 'invitation', 'row'