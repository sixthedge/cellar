import ember       from 'ember'
import util        from 'totem/util'
import totem_scope from 'totem/scope'
import {changeset} from 'ember-changeset/index'
import {validatePresence, validateLength, validateNumber} from 'ember-changeset-validations/validators'
import {validateExclusion, validateInclusion}             from 'ember-changeset-validations/validators'
import {validateConfirmation, validateFormat}             from 'ember-changeset-validations/validators'
import lookup_validator                                   from 'ember-changeset-validations'
# Totem Changeset Mixins:
import m_extend_changeset from 'totem/mixins/changeset/extend_changeset'
import m_validators       from 'totem/mixins/changeset/validators'
import m_numbers          from 'totem/mixins/changeset/numbers'
import m_vdecimals        from 'totem/mixins/changeset/validators/decimals'

totem_changeset = ember.Object.extend m_extend_changeset,
  m_numbers,
  m_vdecimals,
  m_validators,

  vpresence:     -> validatePresence(arguments...)
  vlength:       -> validateLength(arguments...)
  vnumber:       -> validateNumber(arguments...)
  vexclusion:    -> validateExclusion(arguments...)
  vinclusion:    -> validateInclusion(arguments...)
  vconfirmation: -> validateConfirmation(arguments...)
  vformat:       -> validateFormat(arguments...)

  vurl:   (hash={}) -> validateFormat(ember.merge(hash, {type: 'url'}))
  vemail: (hash={}) -> validateFormat(ember.merge(hash, {type: 'email'}))

  # Typically the 'obj' is a model.
  create: (obj, hash)  -> @create_changeset obj, lookup_validator(hash), hash
  no_validation: (obj) -> @create_changeset obj, lookup_validator({}), {}

  create_changeset: ->
    ember_changeset = changeset(arguments...)
    @extend_changeset(ember_changeset).create()

export default totem_changeset.create()
