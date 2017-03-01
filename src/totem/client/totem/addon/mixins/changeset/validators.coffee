import ember from 'ember'

export default ember.Mixin.create

  # Get validator(s) by convention for a validation hash.

  get_validators: (hash) ->
    return [] unless (hash and typeof(hash) == 'object')
    validators = []
    for key, value of hash
      switch key
        when 'number', 'numericality'   then validators.push(v) for v in @number_validators(value)
        when 'presence'                 then validators.push @vpresence(value)
        when 'length'                   then validators.push @vlength(value)
        when 'exclusion'                then validators.push @vexclusion(value)
        when 'inclusion'                then validators.push @vinclusion(value)
        when 'format'                   then validators.push @vformat(value)
        when 'confirmation'             then validators.push @vconfirmation(value)
        when 'email'                    then validators.push @vemail(value)
        when 'url'                      then validators.push @vurl(value)
    validators
