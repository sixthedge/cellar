import ds from 'ember-data'

export default ds.Transform.extend
  deserialize: (serialized) -> serialized
  serialize: (deserialized) -> deserialized
