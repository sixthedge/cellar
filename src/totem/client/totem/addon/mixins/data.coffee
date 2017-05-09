import ember       from 'ember'
import totem_data  from 'totem/mixins/data/base_data'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  viewonly:     ember.computed.reads 'totem_scope.is_view_only'
  not_viewonly: ember.computed.not   'viewonly'

  init: ->
    @totem_data = totem_data.create(source: @)
    @_super(arguments...)


# Overview
#
#     Currently supports data-names 'ability' and 'metadata'.
#
#     Totem data is designed to allow components/templates and models to reference a common
#     data source for each ownerable (e.g. ability, metadata).
#
#     The data is stored by ownerable and can be swapped when the totem_scope 'current user'
#     changes by adding 'current_user_observer: true'.
#
#     The data is stored in ember-data models.  Each totem_data-name module
#     references its own model as resolved by the ns map's ns.to_p('data-name').
#
#     The data may be pre-loaded as part of a server payload or can be obtained by
#     an ajax request.
#
#     If the data-name model has the mixin 'totem/mixins/data/did_load' and totem_data
#     is included in a 'model', the model's data-name data (e.g. can, metadata) is
#     refreshed when the data-name model is loaded (via didLoad hook).
#
#     Alternatively, to refresh the data, a record may be unloaded by another component to generate
#     a new ajax data request.
#
#     The data-name record id:
#       with a single record: "record_path.record_id::ownerable_path.ownerable_id"
#       with a record array:  "component_defined_path::ownerable_path.ownerable_id"
#
#     Each module defines properties on the component.  Currently:
#       ability:  can and cannot
#       metadata: metadata
#
#     Caution: The properties will overwrite any existing properties (a warning is issued).
#
#     A component and template reference the values like:
#       can.update
#       metadata.count

# Usage
#
#     The component or model (e.g. the 'source') must mixin the totem_data mixin and define
#     a 'totem_data_config' property listing the modules to include and their configuration options.
#
#     Each data-name (e.g. ability, metadata) have their own option values.
#     Any key in the 'totem_data_config' hash that is not a data-name is
#     assumed to apply to 'all' data-name configurations (a data-name hash option take precedence).
#
#     If the data-name option value is 'true' (rather than a hash), the data-name will use the default
#     values unless overriden by an 'all' option e.g. ability: true #=> ember.merge({}, all_options).
#
#     WARNING: In order to include a data-name module, the 'totem_data_config' hash MUST include the data-name key
#              (e.g. cannot specify ONLY non-data-name options).
#
#     IMPORTANT: Ajax requests are sent to the data-name model url.  The auth params are based on the
#                configuration options and whether the source 'model' is a record or array of records.
#
#   Configuration options:
#       model:                 string
#       ajax_source:           true|string
#       ajax_method:           string
#       callback:              string (method in the component/model to alter the data e.g. ability/metadata)
#       module_only:           true|false
#       unload:                true|false
#       current_user_observer: true|false
#
#   Configuration option descriptions:
#      model:       default 'model'; the property name of the model
#      ajax_source: default false, data is not required
#                   true -or- string means the data is required and an ajax request is sent unless the record exists
#                   true means a single record and sets the ajax auth params: {model_id and model_type; source is null}
#                   string means use as-is and sets the the ajax auth params: {source: string}
#      ajax_method: default null
#                   string means use as-is and set the ajax params auth: {source_method: string}
#      module_only: default false - set the data-name data
#                   true means include the data-name module but do not set any data; this could be used
#                   by a component to 'unload' a record's data and force a reload of required data (e.g. has an ajax_source)
#      unload:      default false
#                   true means unload the record data before setting the data (e.g. makes an ajax call if has an ajax_source)
#      callback:    method name on the source to change the data-name data before setting on the source (e.g. can abilities)
#                   for example, call a method on a component to change (add/delete) abilities based on some other related model or data
#                   Note: a model with a method called 'add_data-name' (e.g. 'add_ability'), is automatically
#                         called before setting the data on the source
#      current_user_observer: default false
#                             true means add a totem_scope.current_user observer and refresh the data on a change

# Ajax Requests
#
#     How the server responds to ajax requests is platform dependent.
#
#     Ajax requests are sent to the data-name model url with auth params set by the configuration options.
#     If the source model is a single record then the auth params will include the record id and record type.
#
#     params:
#       auth:
#         ownerable_id:   ownerable-id
#        ownerable_type: ownerable-record-type
#        source:         config 'ajax_source' value (if a string)
#        source_method:  config 'ajax_method' value (if a string)
#        * if the source model is a single record the following are added
#        model_id:   model-id
#        model_type: model-record-type

# Process Hooks
#
#     Model records 'add_data-name' function (e.g. add_ability, add_metadata):
#
#       If a record has a function called 'add_data-name' it will be called with the data and the data can
#       be modified as needed.
#       Argurments are (data, module) and the data must be modified in place e.g. not return a new value.
#       Example: assignment model function to equate 'update' to 'gradebook' ability.
#
#     Source callback:
#
#       The data-name module configuration include a callback options, the source method will be called before setting the final values.
#       The arguments are data-name module specific.
#
#     Examples:
#       totem_data_config: ability: callback: 'my_ability_callback'
#
#     Caution: ajax requests for the same id are queued, so 'only' the initiator of the ajax will get
#              populated data in the callback.
#

# thinkspace-authorization
#
#     Currently, the thinkspace-authorization engine constructs a serializer_options 'class' method-name
#     based on the record (when model_id and model_type are present), 'source' and 'source_method'.
#
#     When the 'ajax_method' is present, it is used as-is as the method-name, otherwise the method-name
#     is based on the record or 'ajax_source'.
#
#     The method-name will be taken from a path:
#       path = ajax_source.present? ? ajax_source : record.class.name.underscore.pluralize
#
#     The method-name becomes 'path.camelize.demodulize.downcase' with the final method-name:
#       "#{data-name}_#{method-name}"  #=> e.g. ability_space, ability_spaces, etc.
#
#     The serializer_options 'class' to be called is also determined from the path:
#
#     This serailzer_options method-name is called with args:
#       record:      (controller, record, ownerable)  #=> auth params include model_id and model_type
#       ajax_source: (controller, ownerable)          #=> auth params do 'not' include model_id and/or model_type

# Examples
#
#       totem_data_config:  #=> only include ability module with default option values
#         ability: true
#
#       totem_data_config:  #=> only include metadata module but do not populate any metadata
#         metadata:
#           module_only: true
#
#       totem_data_config:  #=> include both ability and metadata modules with default option values
#         ability:  true
#         metadata: true
#
#       totem_data_config:  #=> change the source's model property to 'mymodel' for both ability and metadata
#         model:    'mymodel'
#         ability:  true
#         metadata: true
#
#       totem_data_config:  #=> require both ability and metadata
#         ability:
#           ajax_source: true
#         metadata: true
#           ajax_source: true
#
#       totem_data_config:  #=> add the source (thinkspace/common/spaces) and source_method to the ajax request for ability and metadata
#         ajax_source: ns.to_p('spaces')
#         ability:
#           ajax_method: 'myability'
#         metadata: true
#           ajax_method: 'mymetadata'
