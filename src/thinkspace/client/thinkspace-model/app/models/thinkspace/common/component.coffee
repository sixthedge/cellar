import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend

  value:         ta.attr()
  preprocessors: ta.attr()

  ember_component: ember.computed.reads 'value.ember.component'
  ember_engine:    ember.computed.reads 'value.ember.engine'



  # ### Builder
  has_builder_content:   ember.computed.notEmpty 'builder_content_path'
  has_builder_preview:   ember.computed.notEmpty 'builder_preview_path'
  has_builder_settings:  ember.computed.notEmpty 'builder_settings_path'

  builder_content_path:  ember.computed 'value.builder', -> @get 'value.builder.paths.content'
  builder_preview_path:  ember.computed 'value.builder', -> @get 'value.builder.paths.preview'
  builder_settings_path: ember.computed 'value.builder', -> @get 'value.builder.paths.settings'
  builder_friendly_name: ember.computed 'value.builder', -> @get 'value.builder.friendly_name'
