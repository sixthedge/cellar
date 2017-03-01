import ember from 'ember'

export default ember.Mixin.create

  convert_to_number: (n) -> Number(n)

  number_of_decimals: (n) ->
    return 0 unless @is_number(n)
    [v, decimals]  = ('' + n).split('.')
    if ember.isBlank(decimals) then 0 else decimals.length

  decimal_value: (n) ->
    return 0 unless @is_number(n)
    [v, decimals]  = ('' + n).split('.')
    if ember.isBlank(decimals) then 0 else Number(decimals)
