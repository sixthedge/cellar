import ember from 'ember'

export default ember.Object.extend
  # # Properties
  data:       null
  components: null

  # # Helpers
  # ## Getters/setters
  get_data:      (property) -> @get("data.#{property}")
  get_component: (property) -> @get("components.#{property}")