import ember            from 'ember'
import base             from 'thinkspace-base/components/base'
import pagination_array from 'totem-application/pagination/arrays/client'

export default base.extend
  tagName: ''
  rows:    null
  columns: null
  server:  false # Whether the rows is a server paginated array.