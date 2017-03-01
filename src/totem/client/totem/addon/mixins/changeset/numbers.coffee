import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  number_validators: (obj) ->
    rules = @convert_number_rules_to_changeset(obj)
    return [] if ember.isBlank util.object_keys(rules)
    validators = [@vnumber(rules)]
    validators.push @vdecimals(rules.decimals) if ember.isPresent(rules.decimals)
    validators

  convert_number_rules_to_changeset: (obj) ->
    return {} unless util.is_hash(obj)
    rules = {}
    for key, value of obj
      ember.merge rules, @convert_number_keys_to_changeset(key, value)
    rules

  convert_number_keys_to_changeset: (key, value) ->
    num = Number(value)
    switch key
      when 'lt', 'lte', 'gt', 'gte'    then {"#{key}": num} # convert as-is with a Number() value if already in changeset format
      when 'less_than'                 then {lt:  num}
      when 'less_than_or_equal_to'     then {lte: num}
      when 'greater_than'              then {gt:  num}
      when 'greater_than_or_equal_to'  then {gte: num}
      when 'decimals'                  then {decimals: num}
      when 'allow_blank'               then {allowBlank: value}
      when 'only_integer'              then {integer: value}
      else {"#{key}": value}
