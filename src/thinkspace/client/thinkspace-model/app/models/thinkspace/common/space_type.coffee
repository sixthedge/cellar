import ember from 'ember'
import ta    from 'totem/ds/associations'
import ds    from 'ember-data'

export default ta.Model.extend ta.add(
    ta.has_many 'spaces', reads: {}
  ),

  title:        ta.attr('string')
  lookup_model: ta.attr('string')

  # component: ember.computed -> @get('lookup_model')

  component: 'cases'
