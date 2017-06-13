import ember from 'ember'

export default ember.Mixin.create

  ## Takes a set of changesets, validates them, then returns a bool of whether the entire set is valid or not
  determine_validity: (cs_arr) ->
    new ember.RSVP.Promise (resolve, reject) =>
      cs_arr     = ember.makeArray(cs_arr)
      validation = ember.makeArray()
      is_valid   = ember.makeArray()

      cs_arr.forEach (cs) =>
        validation.pushObject(cs.validate())

      ember.RSVP.all(validation).then =>
        cs_arr.forEach (cs) =>
          is_valid.pushObject(cs.get('isValid'))

        resolve(!is_valid.contains(false))
