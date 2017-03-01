import ember from 'ember'
import util  from 'totem/util'

default_icon = ['fa', 'fa-file-o']

icon_map = 
  html:  ['fa', 'fa-code']
  text:  ['fa', 'fa-file-text-o']
  image: ['fa', 'fa-camera']
  pdf:   ['fa', 'fa-file-pdf-o']

get_icon_html = (classes) -> new ember.Handlebars.SafeString("<i class='#{classes.join(' ')}'></i>")

export default ember.Helper.helper ([content_type, classes], options={}) ->
  classes = if typeof classes == 'string' then classes.split(' ') else []
  if content_type
    for icon, icon_classes of icon_map
      if util.ends_with(content_type, icon) or util.starts_with(content_type, icon)
        classes.push(icon_class) for icon_class in icon_classes
        break
    if ember.isBlank(classes)
      get_icon_html(default_icon) # return default file icon if content_type does not match an icon
    else
      get_icon_html(classes.uniq())
  else
    get_icon_html(default_icon) # return default file icon if no matching content_type
