import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many 'phases', reads: {}
  ), 

  title:       ta.attr('string')
  description: ta.attr('string')
  template:    ta.attr('string')
  value:       ta.attr()


  image_preview_src:   ember.computed 'value', -> @get('value.images.preview')
  image_thumbnail_src: ember.computed 'value', -> @get('value.images.thumbnail')
