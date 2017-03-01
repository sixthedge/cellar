import ember   from 'ember'
import locales from 'totem-config/locales'

export default ember.Helper.helper ([path], options={}) ->
  str = locales.get_path_or_null(path)
  if ember.isPresent(str)
    str = str.pluralize() if options.plural
  else
    str = "tt '#{path}' not found"
  str.htmlSafe()
