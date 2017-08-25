import ember           from 'ember'
import base            from 'thinkspace-base/components/base'

export default base.extend

  init_base: ->
    @init_query_params()

  init_query_params: ->
    @set 'email', @get_query_param('email')
    @set 'return_url', @get_query_param('return_url')