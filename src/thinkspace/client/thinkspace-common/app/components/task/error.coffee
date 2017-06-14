import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import array from 'thinkspace-common/mixins/helpers/common/array'

export default base.extend array,

  messages: ember.computed 'model.errors.@each', ->
    return ember.makeArray() if ember.isBlank(@get('model'))
    errors = @get('model').get('errors')
    errors = errors.mapBy 'validation'
    @flatten errors