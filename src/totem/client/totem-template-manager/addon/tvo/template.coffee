import ember  from 'ember'
import {mp}   from 'totem-config/config'
import config from 'totem-config/config'
import ns     from 'totem/ns'
import util   from 'totem/util'

export default ember.Object.extend

  parse: (template) -> @_parse(template)

  add_components: (components) -> @_add_components(components)

  get_template: -> @get('$template')

  to_html: -> @get_template().html()
  compile: -> ember.Handlebars.compile @to_html()

  engine_values: (titles, component=null) -> @_engine_values(titles, component)

  engine_path_values: (component, path) -> @_set_engine_path_values(component, path)

  dup_value: (path) ->
    hash         = ember.merge {}, (@tvo.get_path_value(path) or {})
    hash.mounted = false
    hash


  toString: -> 'TvoTemplate'

  # ##################
  # ### Internal ### #
  # ##################

  # ###
  # ### Engine Values (until can pass hash values on {{mount}} e.g. mount 'myengine' component_name='mycomponent').
  # ###

  _engine_values: (titles, component) ->
    titles = ember.makeArray(titles)
    mount = null
    path  = null
    for guid in @tvo.value.get_paths()
      hash = @tvo.value.get_value(guid)
      if titles.includes(hash.title) and not hash.mounted
        path  = guid
        mount = hash
        break
    if ember.isBlank(mount)
      console.error 'No engine values found for any title in:', titles
      return null
    path = "value.#{path}"
    mount.mounted = true
    return path unless component
    @_set_engine_path_values(component, path)
    path

  _set_engine_path_values: (component, path) ->
    hash                 = @tvo.get_path_value(path)
    props                = {}
    props.model          = hash.model
    props.component_name = hash.title.underscore()
    props.attributes     = hash.attributes or {}
    if util.is_hash(hash.values)
      for prop, val of hash.values
        props[prop] = val
    component.setProperties(props)
    hash

  # ###
  # ### Parse Template.
  # ###

  _parse: (template) ->
    $template = $('<div/>').html(template)
    @_set_default_sections($template)
    @_replace_rows($template)
    @_replace_columns($template)
    @set '$template', $template
    @get_template()

  # Default a component's section value to the 'title' attribute if the 'section' attribute is not specified.
  _set_default_sections: ($template) ->
    $components = $template.find('component')
    for component in $components
      $comp = $(component)
      $comp.attr 'section', @tvo.tag_title($comp)  unless $comp.attr('section')

  _replace_rows: ($template) ->
    $rows = $template.find('row')
    for row in $rows
      $row      = $(row)
      $children = $row.children()
      $new_row  = $(@_row_html($row))
      $row.replaceWith($new_row)
      $new_row.append($children)

  _replace_columns: ($template) ->
    $cols = $template.find('column')
    for col in $cols
      $col      = $(col)
      $children = $col.children()
      $new_col  = $(@_col_html($col))
      $col.replaceWith($new_col)
      $new_col.append($children)

  _row_html: ($row) ->
    hash       = @tvo.tag_attribute_hash($row)
    hash.class = @_get_tag_classes($row, 'row')
    @_tag_with_attributes('div', hash)

  _col_html: ($col) ->
    hash = @tvo.tag_attribute_hash($col)
    cols = hash.width or 12
    delete(hash.width)
    columns_class = config.grid.classes.columns
    hash.class    = @_get_tag_classes($col, "#{columns_class} small-#{cols}")
    @_tag_with_attributes('div', hash)

  _tag_with_attributes: (tag, hash) ->
    new_tag = "<#{tag}"
    for own attr_name, attr_value of hash
      new_tag += " #{attr_name}='#{attr_value}'"
    new_tag += '>'
    new_tag

  _get_tag_classes: ($tag, classes='') -> (@tvo.tag_class($tag) + ' ' + classes).trim()

  # ###
  # ### Add Components.
  # ###

  _add_components: (components) ->
    new ember.RSVP.Promise (resolve, reject) =>
      common_component_promises = components.getEach(ns.to_p 'component')
      componentable_promises    = components.getEach('componentable')
      ember.RSVP.Promise.all(common_component_promises).then (common_components) =>
        ember.RSVP.Promise.all(componentable_promises).then (componentables) =>
          component_promises = []
          components.forEach (component, index) =>
            common_component = common_components.objectAt(index)
            componentable    = componentables.objectAt(index)
            component_promises.push @_add_component(common_component, component, componentable)
          ember.RSVP.Promise.all(component_promises).then =>
            resolve()
          , (error) =>
            console.error error

  _add_component: (common_component, component, componentable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @_replace_template_component_html(common_component, component, componentable)
      resolve()

  _replace_template_component_html: (common_component, component, componentable) ->
    section         = component.get('section')
    $comp           = @_get_component_section_tag(section)
    hash            = {}
    hash.attributes = @tvo.tag_attribute_hash($comp)
    hash.model      = componentable
    path            = @tvo.value.set_value(hash)
    bind_properties = @_get_bind_properties($comp, path, hash)
    hash.title      = @tvo.tag_title($comp)
    mount           = common_component.get('ember_engine')
    if ember.isPresent(mount)
      html = "{{mount '#{mount}'}}"
    else
      comp = common_component.get('ember_component')
      html = "{{component '#{comp}' #{bind_properties}}}"
    $comp.replaceWith(html)

  _get_bind_properties: ($comp, path, hash) ->
    keys = []
    keys.push key for own key of hash
    bind = ''
    return bind if ember.isBlank(keys)
    bind += " #{key}=tvo.#{path}.#{key}"  for key in keys
    actions = $comp.data('actions')
    return bind unless actions
    bind += " #{key}='#{value}'"  for own key, value of actions
    bind

  _get_component_section_tag: (section) ->
    $comp  = @get_template().find("component[section=#{section}]")
    length = $comp.length
    switch
      when length > 1
        console.warn "Section [#{section}] is duplicated #{length} times."
        null
      when length < 1
        console.warn "Section [#{section}] is not found."
        null
      else
        $comp
