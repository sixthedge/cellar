import ember from 'ember'

export default ember.Mixin.create

  # startsWith()/endsWith() not implemented in Chrome:
  # => https://code.google.com/p/chromium/issues/detail?id=372976
  starts_with: (string, prefix) ->
    (string or '').indexOf(prefix) == 0

  ends_with: (string, suffix) ->
    (string or '').match(suffix + '$') + '' == suffix

  rjust: (value, length, padding=' ') ->
    [pad, value] = @padding(value, length, padding)
    pad + value

  ljust: (value, length, padding=' ') ->
    [pad, value] = @padding(value, length, padding)
    value + pad

  padding: (value, length, padding) ->
    value = '' if not value and not value == false
    value = value.toString()
    return ['', value] if length and value.length >= length
    pad   = Array(length + 1 - value.length).join(padding)
    return [pad, value]

  pluralize: (str, count=1, plural=null) ->
    return 'bad pluralize string' unless @is_string(str)
    return 'bad pluralize count'  unless @is_integer(count)
    if @convert_to_number(count) > 1 then (plural or str.pluralize()) else str

  string_to_color: (str) ->
    hash = 0
    i    = 0
    while i < str.length
      hash = str.charCodeAt(i) + (hash << 5) - hash
      i++
    color = '#'
    i     = 0
    while i < 3
      value = hash >> i * 8 & 0xFF
      color += ('00' + value.toString(16)).substr(-2)
      i++
    color

  stringify: (obj) -> JSON.stringify(obj)
