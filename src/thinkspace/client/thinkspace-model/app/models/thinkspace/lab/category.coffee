import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'lab:chart', reads: {}
    ta.has_many   'lab:results', reads: {sort: 'position'}
  ), 

  title:    ta.attr('string')
  position: ta.attr('number')
  value:    ta.attr()

  description_heading: ember.computed 'value.description_heading', -> @get('value.description_heading') or 'Description'

  columns:          ember.computed.reads 'value.columns'
  colspan_for_html: ember.computed 'columns', -> @get('columns.length') - 1 # Minus one for the name column.
  component:        ember.computed -> ta.to_p 'lab:category', @get('value.component')
