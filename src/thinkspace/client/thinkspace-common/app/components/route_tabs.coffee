import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  ## Object format
  ## => {path: 'string', external: {true/false}, display: 'string'}
  ## => path:     denotes what route the link should point to
  ## => external: determines what link-to helper should be used
  ## => display:  determines what text will be displayed

  model: null # Array of objects