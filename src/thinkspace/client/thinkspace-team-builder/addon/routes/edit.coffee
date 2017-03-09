import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend
  
  model: (params) -> 
    console.log("params are ", params)
    @tc.find_record_with_message(ns.to_p('team'), params.team_id)
