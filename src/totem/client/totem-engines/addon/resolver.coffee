import ember    from 'ember'
import util     from 'totem/util'
import Resolver from 'ember-engines/resolver'

# A new instanace of this resolver class is created for each engine instance.
# An engine's module-prefix is defined in the engine's 'modulePrefix' value in 'config/environment.js'
# which is currently the same as the package name (e.g. thinkspace-phase)
#
# There are three custom naming conventions to set the pn.root:
#   * For HELPERS, replace '__' with '--' (hyphens)
#   1. [__|app__]               #=> main application                       e.g. component '__layout' or component 'app__layout'
#   2. [parent__]               #=> parent owner of the current pn.root    e.g. component 'parent__layout'
#   3. [engine-module-prefix__] #=> pn.root or an ANCESTOR of pn.root      e.g. component 'thinkspace-phase__layout'
#
# Can NOT use an engine-module-prefix in a current-engine template for an engine 'mounted' by the current-engine (e.g. a child engine).
# Can NOT use an engine-module-prefix for an engine that is NOT already 'mounted'.
# CAN use an engine-module-prefix for an 'ancestor' engine of the current-engine (e.g. up the current-engine owner mount-chain).
#
# Notes:
#   1. If want to reference an 'app' component, use [__|app__].  Do not use the app's module-prefix (e.g. orchid__) since may change.
#   2. An engine-module-prefix can be the underscored value if desired (e.g. thinkspace-phase__layout or thinkspace_phase__layout).
#
# CAUTION: A component in another engine is still being resolved the context of the CURRENT-engine.  Therefore when referencing another engine,
#   * any template 'link-to-external' routes must be defined in the current-engine
#   * another engine's template that calls components or partials must use '__' (e.g. main app) or 'engine-module-prefix__'
#     since is in the current-engine's context.
#     * One technique is to use the engine's own module-prefix in its templates for components/templates (e.g. the module-prefix of engine itself).
#     * Another technique is to use 'parent__' if it will always be used by a mounted child engine (but cannot be used by the engine itself).

export default Resolver.extend

  name_variables: ['fullName', 'fullNameWithoutType', 'name']

  engine_owners: {}

  resolveTemplate: (pn) -> # 'resolveTemplate' does not call 'resolveOther' so need to process separately.
    @set_pn_root(pn)
    @_super(pn)

  resolveOther: (pn) ->
    @underscore_pn(pn) unless pn.type == 'helper'
    @set_pn_root(pn)
    @_super(pn)

  # ###
  # ### Set Owner in Parsed Name Object (pn).
  # ###

  set_pn_root: (pn) ->
    return if ember.isBlank(pn.root)
    switch pn.type
      when 'helper'  then @set_owner(pn, '--')
      else                @set_owner(pn, '__')

  set_owner: (pn, match) ->
    return unless pn.name.match(match)
    regex    = RegExp if pn.name.match("^components/") then "^components/(.*)#{match}" else "^(.*)#{match}"
    pn_match = pn.name.match(regex)
    return if ember.isBlank(pn_match)
    key         = pn_match[1]
    key_replace = "#{key}#{match}"
    @replace_pn(pn, key_replace)
    key   = 'app' if key == ''
    key   = @underscore_string(key)
    owner = (@engine_owners[key] ?= @get_key_owner(pn, key))
    @error_resolve "No owner found for key '#{key}'.\n", pn, match, pn_match if ember.isBlank(owner)
    prefix = @get_module_prefix(owner)
    @error_resolve "No prefix found for key '#{key}'.\n", pn, match, pn_match if ember.isBlank(prefix)
    @set_new_owner(pn, owner, prefix)

  get_key_owner: (pn, key) ->
    switch key
      when 'app'     then @get_app_owner(pn)
      when 'parent'  then @get_parent_owner(pn)
      else                @get_engine_owner(pn, key)

  get_app_owner: (pn) ->
    root   = @get_owner(pn.root)
    router = root.lookup('router:main')
    return null if ember.isBlank(router)
    @get_owner(router)

  get_parent_owner: (pn) ->
    @get_owner(pn.root)

  get_engine_owner: (pn, key) ->
    mod_prefix = key.dasherize()
    @find_ancestor_engine(pn.root, mod_prefix)

  find_ancestor_engine: (owner, mod_prefix) ->
    return null unless owner
    return owner if mod_prefix == @get_module_prefix(owner)
    parent = @get_owner(owner)
    return null unless parent
    @find_ancestor_engine(parent, mod_prefix)

  # ###
  # ### Helpers.
  # ###

  get_owner: (current)       -> ember.getOwner(current)
  get_module_prefix: (owner) -> owner and (owner.modulePrefix or owner.application?.modulePrefix or owner.base?.modulePrefix)

  set_new_owner: (pn, root, prefix) ->
    pn.root   = root
    pn.prefix = prefix

  replace_pn: (pn, match) -> pn[prop] = pn[prop].replace(match, '')   for prop in @name_variables
  underscore_pn: (pn)     -> pn[prop] = @underscore_string(pn[prop])  for prop in @name_variables

  underscore_string: (val) -> (val and ember.String.underscore(val)) or ''

  error_resolve: (args...) -> util.error @, args..., @

  debug_pn: (pn, title='') ->
    console.warn title
    keys = util.hash_keys(pn).sort()
    console.info key, ' -> ', pn[key] for key in keys
