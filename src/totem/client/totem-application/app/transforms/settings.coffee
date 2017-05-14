import ds from 'ember-data'
import ember from 'ember'

export default ds.Transform.extend
  deserialize: (serialized) -> serialized
  serialize: (deserialized) -> deserialized
