import ember from 'ember'

export default ember.Mixin.create 
  reset_properties_to_default: ->
    default_property_settings = @get('default_property_settings')
    return unless default_property_settings
    for key, value of default_property_settings
      if value? and value.type
        switch
          when 'array'
            @set("#{key}", [])
      else
        @set("#{key}", value)
