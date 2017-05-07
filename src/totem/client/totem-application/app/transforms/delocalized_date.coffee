import ds from 'ember-data'

export default ds.Transform.extend
  deserialize: (serialized) ->
    type = typeof serialized

    # This checks the incoming date from rails, then creates a new javascript date object that
    # will be timezone independant by grabbing the offset from UTC then setting the hours (which are
    # defaulted to local time) to match UTC 00:00
    if type == "string" 
      date             = new Date(Ember.Date.parse(serialized))
      offset_date      = new Date(date.getTime() + (date.getTimezoneOffset() * 60000))
      return offset_date
     else if type == "number"
      return new Date(serialized)
    else if (serialized == null or serialized == undefined)
      return serialized
    else
      return null

  serialize: (date) ->
    if date instanceof Date
      offset_date = new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
      offset_date.toJSON()
    else 
      return null