import ember from 'ember'
import ns         from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  layoutName: 'thinkspace/common/user/password/confirmation'

  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'shared', 'loader'


  #  added by routes migration
  r_users_sign_in: ns.to_r 'users', 'sign_in'
