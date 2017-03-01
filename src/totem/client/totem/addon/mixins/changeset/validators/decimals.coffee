import ember from 'ember'

export default ember.Mixin.create

  vdecimals: (max_decimals=0) ->
    return (key, vnew, vold, changes) ->
      return true unless vnew
      not_allowed = 'Decimals are not allowed'
      str = '' + vnew
      return not_allowed if max_decimals <= 0 and str.match(/\./)
      [v, digits]  = str.split('.')
      num_decimals = (digits and digits.length) or 0
      return true if (num_decimals <= max_decimals)
      if (max_decimals <= 0) then not_allowed else "Decimals must be less than #{max_decimals}"
