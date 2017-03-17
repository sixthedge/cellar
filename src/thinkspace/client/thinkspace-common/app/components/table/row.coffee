import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  row: null

  actions:
    cell_click: (cell) ->
      console.log('cell_click fired with cell ', cell)