import ember   from 'ember'
import locales from 'totem-config/locales'

console.warn locales

class i18n

  message: (options={}) ->
    template = @template(options)
    @format_message(template, options)

  format_message: (template, options) ->
    args    = ember.makeArray(options._i18n_args or [])
    message = template.fmt(args...)
    message = @humanize(message)  unless options.humanize == false
    message

  template:(options={}) ->
    path               = options.path
    template           = locales.get_path(path) if path
    options._i18n_args = options.args if template
    unless template
      default_path       = options.default_path
      template           = locales.get_path(default_path) if default_path
      options._i18n_args = options.default_args if template
    template = 'Missing i18n template'  unless template
    template

  humanize: (str) ->
    "#{str}".replace(/_/g, ' ').replace( /^\w/g, (s) -> s.toUpperCase() )

export default new i18n
