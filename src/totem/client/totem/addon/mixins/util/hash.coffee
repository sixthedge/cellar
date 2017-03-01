import ember from 'ember'

export default ember.Mixin.create

  has_key: (obj, key) -> @is_hash(obj) and @is_string(key) and @hash_keys().includes(key)

  has_keys:    (obj) -> ember.isPresent @object_keys(obj)
  hash_keys:   (obj) -> @object_keys(obj) # alias for object_keys
  hash_values: (obj) -> @is_hash(obj) and ((v) for k, v of obj)
  dup_hash:    (obj) -> ember.assign {}, (@is_hash(obj) and obj) or {}

  object_keys: (obj) -> (@is_hash(obj) and Object.keys(obj)) or []

  flatten_hash: (hash, sep='.') ->
    return {} unless @is_hash(hash)
    result = {}
    for key in @hash_keys(hash)
      value = hash[key]
      if @is_hash(value)
        value = @flatten_hash(value, sep)
        for suffix in @hash_keys(value)
          result["#{key}#{sep}#{suffix}"] = value[suffix]
      else
        result[key] = value
    result

  delete_blank_hash_keys: (hash) ->
    (delete(hash[key]) if ember.isBlank(hash[key])) for key in @object_keys(hash)

  delete_blank_hash_keys_except: (hash, except...) ->
    (delete(hash[key]) if ember.isBlank(hash[key]) and not except.includes(key)) for key in @object_keys(hash)

  # Compare hasha key values with hashb (keys will default to hasha keys).
  # Uses ember.isEqual on values so objects (e.g. arrays, hashes) must be the same reference.
  hash_values_equal: (hasha, hashb, keys=null) ->
    return false unless @is_hash(hasha)
    return false unless @is_hash(hashb)
    keys ?= @hash_keys(hasha)
    return false if ember.isBlank(keys)
    for key in keys
      return false unless ember.isEqual(hasha[key], hashb[key])
    true
