import ember from 'ember'

export default ember.Mixin.create

## ###
## Promise Helpers
## ###


  # calls ember.RSVP.hash and sets the key value pairs on the provided context afterwards
  rsvp_hash_with_set: (promises, context, prepend='', append='') ->
    ember.RSVP.hash(promises).then (results) ->
      for key, value of results
        context.set "#{prepend}#{key}#{append}", value
      results

  # resolves a value if it is a promise, otherwise resolves the passed in value
  resolve_promise: (promise) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if promise.then?
        promise.then (resolution) =>
          resolve resolution
      else
        resolve promise

