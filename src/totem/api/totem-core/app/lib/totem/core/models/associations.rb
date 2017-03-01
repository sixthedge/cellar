# CAUTION: The resolved_model_definitions are loaded 'once'.  Any changes will require a server restart.
#
# IMPORTANT: All association names are fully qualified, even when in the same engine. For example:
#   * The 'user_responses' association in Platform::Tools::HelperEmbeds::InputElement::Element is
#     'platform_tools_helpers_input_element_user_responses' not 'user_responses'
#   * This is for consistency and similar to the ember paths.  Foreign keys are added as needed.
#
# Dynamically add a model's associations and the model-serializer's associations as defined in a model definitions file.
# The file 'engines/totem-core/lib/totem/core/engine.rb' adds a 'totem_associations' method to ActiveRecord::Base.
# When this method is called in a model, it will add the associations defined via this implementation.
#
# totem_associations options:
#   model: [true|false]       #=> [optional] any other value or not specified = true
#                             #=> true = add model associations; false = do not add model associations
#   serializer: [true|false]  #=> [optional] any other value or not specified = true
#                             #=> true = add serializer associations; false = do not add serializer associations
#   serializer_class:         #=> [optional] full class name as a string (defaults to model.name + 'Serializer')
#                             #=> e.g. 'Platform::Tools::HelperEmbeds::InputElement::SuperSerializer'
#
# Typical use:
#   #. Add associations to model and serializer:
#     class Element < ActiveRecord::Base; totem_associations; end
#     class ElementSerializer < Totem::Settings.class.totem.base_serializer; end
#   #. Add associations to the model's serializer but not the model itself:
#     class Element < ActiveRecord::Base; totem_associations model: false; end
#     class ElementSerializer < Totem::Settings.class.totem.base_serializer; end
#   #. Add associations to the model but not the model's serializer:
#     class Element < ActiveRecord::Base; totem_associations serializer: false; end
#
# Unless there are custom methods in the model or serializer, the classes are empty except for
# the 'totem_associations' method in the model.  If custom method alread exist, they will not be overriden.
# Serializer classes will be auto-created if they do not exist.
#
# To see the associations added, run:
#   rake TASKNAME='association:list' totem:association:list
module Totem
  module Core
    module Models
      class Associations

        attr_reader :totem_settings

        attr_reader :warnings
        attr_reader :resolved_model_definitions

        ASSOCIATIONS_SERIALIZER_ONLY_OPTIONS  = [:serialize, :authorize]
        SERIALIZER_METHODS_DELEGATED_TO_SCOPE = [:current_user, :current_ability, :serializer_options]
        ASSOCIATIONS_KEYS_WITH_SYMBOL_VALUES  = [:dependent]

        def initialize(env)
          @totem_settings = env
        end

        def reset!  # reload the associations.yml files on next request
          @resolved_model_definitions = nil  if ::Rails.env.development?
        end

        # ######################################################################################
        # @!group Entry Point
        # Called in models using the 'totem_associations' class method added by the totem_core
        # engine to ActiveRecord::Base.
        # Model is a 'class', so need to verify its 'ancestors' include ActiveRecord::Base
        # since do not want to create a new model instance just to call 'kind_of?'.
        def perform(model, options)
          return if ::Totem::Settings.config.startup_no_associations?
          error "Model class is blank"  if model.blank?
          error "Model is not a subclass of ActiveRecord::Base or ActiveModel::Model [#{model.inspect}]"  unless model.ancestors.include?(ActiveRecord::Base) or model.ancestors.include?(ActiveModel::Model)
          setup
          return if resolved_model_definitions.blank?
          return unless continue_perform?
          log_model_separator(model)  if log?
          model_definition = find_model_definition(resolved_model_definitions, model.name)
          error "Missing model association definition for model [#{model.name}]"  unless model_definition.present?
          model_def = model_definition.deep_dup
          add_model_associations(model, model_def, options)            unless options[:model] == false
          add_model_delegates(model, model_def, options)               unless options[:model] == false
          add_model_serializer_associations(model, model_def, options) unless options[:serializer] == false
        end

        private

        def continue_perform?
          true
        end

        # Will run once to setup the resolved_model_definitions instance variable and
        # set whether is initiated by a rake task.
        def setup
          return if resolved_model_definitions.present?
          @is_rake_task             = false
          @is_rake_association_task = false
          @warnings                 = nil
          @log                      = false
          @log_clean                = false
          check_rake_task
          @resolved_model_definitions = resolve_model_definition_classes_and_values
        end

        include Totem::Core::Support::Shared
        include AssociationsLogger
        include Definitions
        include AssociationsModel
        include AssociationsSerializer

        # ######################################################################################
        # @!group Main - Model Associations

        def add_model_associations(model, mdef, options)
          associations = mdef[:associations] || []
          associations.each do |association|
            association = association.except(*ASSOCIATIONS_SERIALIZER_ONLY_OPTIONS)
            ASSOCIATIONS_KEYS_WITH_SYMBOL_VALUES.each do |key|
              next unless association.has_key?(key)
              value            = association[key]
              association[key] = value.to_sym if value.present? && value.is_a?(String)
            end
            add_model_association(model, association, options)
          end
        end

        # ######################################################################################
        # @!group Main - Model Delegates

        def add_model_delegates(model, mdef, options)
          delegates = mdef[:delegate] || []
          delegates.each do |delegate|
            methods = [delegate[:method]].flatten.compact
            error "Delegate :method is blank [#{model.name}]"  if methods.blank?
            methods = methods.collect {|m| m.to_sym}
            methods.each do |method|
              error "Delegate method [#{method.inspect}] already exists on [#{model.name}]"  if model.method_defined?(method)
            end
            to = delegate[:to]
            error "Delegate method #{methods} to: is blank [#{model.name}]"  if to.blank?
            error "Delegate method #{methods} to: must be a symbol or string not [#{to.class.name}] [#{model.name}]"  unless to.instance_of?(String) || to.instance_of?(Symbol)
            to = to.to_s.gsub('/','_').to_sym
            error "Delegate :to [#{to.inspect}] does not exist on [#{model.name}]"  unless model.method_defined?(to)
            options             = Hash.new
            options[:to]        = to
            options[:allow_nil] = delegate[:allow_nil] != false
            options[:prefix]    = delegate[:prefix]  if delegate.has_key?(:prefix)
            log_model_association(model, :delegate, methods, options)  if log?
            model.send :delegate, *methods, options
          end
        end

        # ######################################################################################
        # @!group Main - Serializer Associations

        def add_model_serializer_associations(model, mdef, options)
          return if ::Totem::Settings.config.startup_no_serializers?
          serializers = get_serializer_definitions_for_model(model, mdef, options)
          serializers.each do |hash|
            serializer_class = hash.delete(:class)
            error "Serializer class is blank [#{hash.inspect}]"  if serializer_class.blank?
            serializer = serializer_class.safe_constantize
            error "Cannot constantize model serializer name [#{serializer_class}]"  if serializer.blank?
            log_serializer_separator(model, serializer)  if log?
            root = model.name.underscore
            serializer.type(root)   # set the root as the serializer's model
            add_serializer_method_delgates(serializer)  # delegate methods to :scope (e.g. current_user, current_ability, etc.)
            add_platform_serializer_modules(model, serializer)
            hash[:values].each do |association|  # association is a belongs_to, has_one, has_many or another hash like attributes
              add_serializer_association(model, serializer, association)
            end
          end
        end

        def add_serializer_method_delgates(serializer)
          SERIALIZER_METHODS_DELEGATED_TO_SCOPE.each do |method|
            serializer.send :delegate, method, to: :scope
          end
        end

        # Currently, the only authorization related modules are defined.
        def add_platform_serializer_modules(model, serializer)
          modules = totem_settings.authorization.current_serializer_include_modules(model) || []
          modules.each do |mod|
            serializer.send(:include, mod)
          end
        end

        # ######################################################################################
        # @!group Serializer Class

        # The model's serializers: primary key section consists of an array of hashes (e.g. like the associations: key).
        # Common serializer values (e.g. a hash key: value) are added under the serailizers: primary key
        # (these hashes must not contain a key of 'serailizer') and are inherited by all the model's serializers.
        #
        # Each of the primary key 'serializers:' hashes with a 'serializer:' key (e.g. singular) is
        # a serializer configuration and if found, only these configurations are used.
        # This hash configuration must contain all the serailizer's associations (e.g. has_one and has_many).
        # Any keys that match a common key will override the common value.
        # See 'get_serializer_class_name' for information on defining the class name of this kind of serializer.
        # Note: Defining multiple serializers in this way is rarely needed after the 'serializer options'
        # functionality was implemented that allows a single serializer to perform differently
        # based on the serializer options.
        #
        # If none of the 'serializers:' hashes has a 'serializer:' key, the default serializer class of:
        # "model.name + Seriazlier" is used.  If this class does not exist, a new class is created
        # by extending the platform's :base_serializer class (defined by the platform's config.yml file).
        # Then the model's associations (e.g. from the model's associations: primary key) are copied
        # to become the serializer's associations.
        # The model's associations are copied per below unless the association contains the key/value:
        # 'serialize: false' to skip the association.
        #   1. belongs_to polymorphics
        #   2. An association that references the model itself (e.g. association's model class matches
        #      the current model's class) such as:
        #      * parent-child
        #      * aliased name
        #   3. The association's model has a model definition that contains a serializer definition
        #      e.g. a lookup is done on the association's model and its model definition is checked for
        #      serializer definition.
        #      * This conditional will typically remove :through associations (unless they have a serializer defined).
        #
        # Common usage:
        #   - model: platform/common/user
        #     associations:
        #       - belongs_to ...
        #       - has_one ...
        #       - has_many ...
        #     serailizers:
        #       - attributes: [id, title]
        #   result: Platform::Common::UserSerailizer class created or updated with belongs_to, has_one and has_many associations.

        def get_serializer_definitions_for_model(model, mdef, options)
          common_serializer_values = get_common_serializer_values(mdef)
          serializers              = get_model_definition_serializers(mdef)
          return [] if serializers.blank? && common_serializer_values.blank?
          if serializers.blank?  # no serializer defined so copy associations from model's associations
            serializers = get_default_serializer_associations(model, mdef, options)
          end
          serializer_definitions = []
          classes_processed      = []
          common_serializer_keys = common_serializer_values.keys
          serializers.each do |serializer|  # serializer is an array of hashes that define it
            serializer_class = get_serializer_class_name(model, serializer, options)
            error "Serializer class [#{serializer_class.inspect}] is a duplicate"  if classes_processed.include?(serializer_class)
            classes_processed.push(serializer_class)
            serializer_keys = serializer.collect {|a| a.keys}.flatten.compact.uniq
            keys_to_add     = common_serializer_keys - serializer_keys
            hashes_to_add   = []
            keys_to_add.each do |key|
              hashes_to_add.push( {key.to_sym => common_serializer_values[key].deep_dup} )
            end
            values = hashes_to_add + serializer  # add array of common hash values to serializer array of hashes
            serializer_definitions.push( {class: serializer_class, values: values} )
          end
          serializer_definitions
        end

        # No serializer is defined in the 'serailizers' section (e.g. no hash with a 'serializer' key).
        # If the serializer class (model.name + Serializer) does not exsit, create a new serializer class.
        # Transfer the model's associations to become the serializer's associations.
        # To skip adding an association to the serializer, set 'serialize: false' in association's definition.
        def get_default_serializer_associations(model, mdef, options)
          serializer_associations = []
          serializer_class_name   = model.name + 'Serializer'
          serializer              = serializer_class_name.safe_constantize

          # Create a serializer class if it does not exist.
          create_default_serializer_class(model, serializer_class_name)  if serializer.blank?

          # Transfer the model's associations to become the serailizer's associations.
          (mdef[:associations] || []).each do |association|
            next if association[:serialize] == false
            next unless association[:valid_class]
            unless is_self_model_association?(model, association) # if association for the current model itself e.g. polymorphic
              association_model_class = get_association_model_class(association)
              model_definition        = find_model_definition(resolved_model_definitions, association_model_class)
              error("Missing model #{model.name.inspect} definition for association model class #{association_model_class.inspect}")  if model_definition.blank?
              next unless model_definition[:serializers].present?  # skip this association since not serialized
            end
            serializer_association             = association.deep_dup  # first copy the model's association
            serializer_association[:authorize] = association[:authorize] == false ? false : true
            if (belongs_to = serializer_association.delete(:belongs_to)).present?
              serializer_association[:has_one] = belongs_to # ASM only uses has_one
            end
            serializer_associations.push serializer_association
          end

          [serializer_associations]
        end

        def get_common_serializer_values(mdef)
          common_serializer_values = HashWithIndifferentAccess.new
          if (mdef_serializers = mdef[:serializers])
            mdef_serializers.each do |serializer|
              next if serializer.has_key?(:serializer)
              serializer.each_pair do |key, value|
                common_serializer_values[key] = value
              end
            end
          end
          common_serializer_values
        end

        def get_serializer_class_name(model, serializer, options)
          suffix = serializer.collect {|a| a[:suffix]}.compact.first
          prefix = serializer.collect {|a| a[:prefix]}.compact.first
          klass  = serializer.collect {|a| a[:class]}.compact.first
          serializer.delete_if {|a| a[:suffix]}  # delete configuration hashes (e.g. not serializer options)
          serializer.delete_if {|a| a[:prefix]}
          serializer.delete_if {|a| a[:class]}
          serializer_class = klass || options[:serializer_class] || model.name
          if prefix.present?
            ns   = serializer_class.deconstantize
            name = serializer_class.demodulize
            serializer_class = ns + '::' + prefix.classify + name
          end
          serializer_class = serializer_class + suffix.classify  if suffix.present?
          serializer_class += 'Serializer'
          serializer_class
        end

        # Create a new serailizer class (model.name + 'Serializer') by extending the platform's :base_serializer.
        def create_default_serializer_class(model, serializer_class_name)
          platform_name = totem_settings.engine.current_platform_name(model)
          error("Platform name for model #{model.inspect} is blank.")  if platform_name.blank?
          extend_class = totem_settings.class[platform_name.to_sym].get_class(:base_serializer)
          error("Unknown base serializer class for platform name #{platform_name.inspect}.")  if extend_class.blank?
          klass          = Class.new(extend_class)
          namespace_name = serializer_class_name.deconstantize
          namespace      = namespace_name.safe_constantize
          serializer     = namespace.const_set(serializer_class_name.demodulize, klass)
          error("Serializer class #{serializer_class_name.inspect} could not be constantized.")  if serializer.blank?
          debug "Created serializer #{serializer.name.inspect}"  unless is_rake_task?
        end

        def is_self_model_association?(model, association)
          belongs_to = association[:belongs_to]
          return true if belongs_to.present? && is_polymorphic?(association)
          return true if get_association_model_class(association) == model.name
          false
        end

        def get_association_model_class(association)
          association[:belongs_to] || association[:has_one] || association[:has_many]
        end

        # ######################################################################################
        # @!group Common Errors and Warnings

        def warning(message)
          if log_clean?
            message = "[WARNING]: #{message}"
          else
            message = "[WARNING] #{self.class}: #{message}"
          end
          if is_rake_association_task?
            @warnings.push(message)
          end
          puts message
          Rails.logger.warn message
        end

      end

    end
  end
end
