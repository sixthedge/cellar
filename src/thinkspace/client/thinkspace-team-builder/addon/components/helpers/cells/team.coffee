import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns    from 'totem/ns'

export default base.extend

  title: ember.computed.reads 'row.computed_title'
  team:  ember.computed.reads 'row.team'
  color: ember.computed.reads 'team.color'

  has_color: ember.computed.notEmpty 'color'
