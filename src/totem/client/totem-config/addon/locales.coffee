import ember  from 'ember'
import util   from 'totem/util'
import config from 'totem-config/config'
import {env}  from 'totem-config/config'
import fm     from 'totem-config/find_modules'
import compile_template from 'ember-i18n/utils/i18n/compile-template'
import missing_message  from 'ember-i18n/utils/i18n/missing-message'

TotemLocales = ember.Object.extend

  locales:        ember.Object.create()
  current_locale: ember.Object.create()
  current_code:   null
  i18n_service:   null

  get_path_or_null: (path) ->
    @error 'i18n path is blank.' if ember.isBlank(path)
    @current_locale[path] or null

  get_path: (path) ->
    @error 'i18n path is blank.' if ember.isBlank(path)
    @current_locale[path] or "Missing i18n for '#{path}'"

  all_codes: -> util.hash_keys(@locales)

  get_default_code: -> (env.i18n or {}).defaultLocale or 'en'
  get_current_code: -> @current_code or @get_default_code()

  set_current_locale: (code=@get_default_code()) ->
    @error "Locale code is blank in set_current_locale." if ember.isBlank(code)
    @current_code = code
    @warn "Locales code '#{code}' translations are blank." if ember.isBlank(@locales[code])
    @current_locale = @locales[code] or @get_new_locale()
    @i18n_service.set('locale', code) if ember.isPresent(@i18n_service)

  process: (instance) ->
    @i18n_service = instance.lookup('service:i18n')
    @error "ember-i18n 'i18n' service not found." if ember.isBlank(@i18n_service)
    @register_ember_i18n_helpers(instance)
    @load_locales()
    @set_current_locale()

  load_locales: ->
    codes = @get_mod_codes()
    for code in codes
      base  = @locales[code]
      base  = @locales[code] = @get_new_locale() if ember.isBlank(base)
      regex = new RegExp "\/locales\/#{code}$"
      mods  = fm.filter_by(regex)
      for mod in mods
        hash = util.require_module(mod)
        @error "Module '#{mod}' is not a hash."  unless util.is_hash(hash)
        for key, value of util.flatten_hash(hash)
          if ember.isPresent(base[key])
            @warn "Key '#{key}' in module '#{mod}' is a duplicate and ignored. Duplicate value '#{value}'. Keeping value '#{base[key]}'.  "
          else
            base[key] = value
      @i18n_service.addTranslations(code, base) if ember.isPresent(@i18n_service)

  # Get locale codes from module paths in a 'locales' directory.
  get_mod_codes: ->
    regex = new RegExp "\/locales\/\\w\\w$"
    mods  = fm.filter_by(regex)
    codes = []
    len   = 2
    for mod in mods
      code = mod.split('/').pop()
      if ember.isPresent(code) and not codes.includes(code)
        if code.length != len
          @warn "Locales module '#{mod}' code-file-name '#{code}' is invalid (must be #{len} characters)."
        else
          codes.push(code)
    codes

  # Register the default ember-i18n util functions so can use lookupFactory.
  # 'ember-i18n/util/locale.js' uses:
  #   const compile = this.owner._lookupFactory('util:i18n/compile-template');
  #   const missingMessage = this.owner._lookupFactory('util:i18n/missing-message');
  register_ember_i18n_helpers: (instance) ->
    instance.register('util:i18n/compile-template', compile_template, instantiate: false)
    instance.register('util:i18n/missing-message', missing_message, instantiate: false)

  get_new_locale: -> ember.Object.create()

  warn:  (message='') -> util.warn(@, message)
  error: (message='') -> util.error(@, message)

  toString: -> 'TotemLocales'

export default TotemLocales.create()
