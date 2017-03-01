module Totem
  module Core
    module Models
      module AssociationsSerializer

        # ######################################################################################
        # @!group Serializer Association Detail

        def add_serializer_association(model, serializer, association)
          platform_name = totem_settings.engine.current_platform_name(model)
          association   = standardize_serializer_values(serializer, association, platform_name)

          valid_class = association.delete(:valid_class)
          valid_class = true unless valid_class.present? # Handle ATTRIBUTES case.
          return warning "Invalid class for serializer [#{model}] and association [#{association.inspect}], skipping so any reference will result in an error." unless valid_class

          case

          ## HAS ONE
          when assoc_class = association[:has_one]
            add_serializer_has_one(model, serializer, assoc_class, association)

          ## HAS MANY
          when assoc_class = association[:has_many]
            add_serializer_has_many(model, serializer, assoc_class, association)

          ## ATTRIBUTES (current model attributes to include in the serialized json)
          when attrs = association[:attributes]
            validate_attributes_in_model_table(model, attrs, serializer)
            unless attrs.include?(:id)
              warning "Serializer attributes for model [#{model.name}] does not contain an 'id' column -> being added"
              attrs.push(:id)
            end
            log_serializer_association(model, :attributes, serializer, attrs) if log?
            serializer.attributes(*attrs)

          ## SCOPED ATTRIBUTES (add as normal attributes but create a serializer method that calls the record's attribute method name passing scope)
          when scoped = association[:scoped_attributes]
            add_scoped_serializer_methods(model, serializer, scoped)

          ## ATTRIBUTE (model attribute to include in the serialized json)
          #    The attribute value can be either:
          #      * A polymorphic reference (e.g. configurable) contained in the current model
          #        * The reference will have both '_id' and '_type' attributes added as well
          #          as adding the polymorphic method.
          #      * A path to another model  (e.g. authentication/user)
          #        * The path has been resolved to the fully qualified model class in the defintions and therefore,
          #          adds '_id' to the demodulized name (e.g. Totem::Authentication::User -> user_id)
          #          and adds the fully qualified :key option (e.g. totem/authentication/user_id).
          #    The attribute id and/or type should not be included the 'attributes' list.
          #    Other current model attributes should be listed in the :attributes option.
          when attr_name = association[:attribute]
            if is_polymorphic?(association)
              log_serializer_association(model, :attribute, serializer, attr_name, association) if log?
              add_polymorphic_id_and_type_attributes(model, serializer, association, attr_name)
              add_polymorphic_method_to_serialzer(model, serializer, attr_name)
            else
              assoc_class       = attr_name.dup
              attr_name         = assoc_class.demodulize.underscore + '_id'
              attr_name         = attr_name.to_sym
              association[:key] = assoc_class.underscore + '_id'
              serializer.attribute(attr_name, association)
              log_serializer_association(model, :attribute, serializer, attr_name, association) if log?
            end

          ## ERROR
          else
            error "Class [#{serializer.name}] has unknown serializer association [#{association.inspect}]"
          end

        end

        # ######################################################################################
        # @!group Add Methods/Requirements

        SERAILZER_ASSOCIATION_KEYS = [:root, :key, :polymorphic]

        def add_serializer_has_one(model, serializer, assoc_class, association)
          assoc_name = association[:name]
          authorize  = association[:authorize]
          unless is_polymorphic?(association)
            assoc_root_name    = assoc_class.underscore
            association[:root] = assoc_root_name.pluralize
            json_key           = get_json_key(association, assoc_root_name, assoc_name)
            association[:key]  = json_key
          end
          existing_method     = serializer_authorize_association_method_exists?(model, serializer, assoc_name)
          has_one_association = association.slice(*SERAILZER_ASSOCIATION_KEYS)
          log_serializer_association(model, :has_one, serializer, assoc_name, has_one_association) if log?
          serializer.has_one(assoc_name, has_one_association)
          add_polymorphic_method_to_serialzer(model, serializer, assoc_name)         if is_polymorphic?(association)
          add_serializer_authorize_has_one(model, serializer, assoc_name, authorize) unless existing_method.present?
          serializer_warnings(model, association, assoc_name)
        end

        def add_serializer_has_many(model, serializer, assoc_class, association)
          assoc_name           = association[:name]
          authorize            = association[:authorize]
          assoc_root_name      = assoc_class.underscore.pluralize
          association[:root]   = assoc_root_name
          json_key             = get_json_key(association, assoc_root_name, assoc_name)
          association[:key]    = json_key
          existing_method      = serializer_authorize_association_method_exists?(model, serializer, assoc_name)
          has_many_association = association.slice(*SERAILZER_ASSOCIATION_KEYS)
          log_serializer_association(model, :has_many, serializer, assoc_name, has_many_association) if log?
          serializer.has_many(assoc_name, has_many_association)
          add_serializer_authorize_has_many(model, serializer, assoc_name, authorize) unless existing_method.present?
          serializer_warnings(model, association, assoc_name)
        end

        # ######################################################################################
        # @!group Polymorphic Id and Type

        def add_polymorphic_id_and_type_attributes(model, serializer, association, attr_name)
          id_name   = "#{attr_name}_id".to_sym
          type_name = "#{attr_name}_type".to_sym
          validate_attributes_in_model_table(model, [id_name, type_name], serializer)
          serializer.attribute(id_name)
          log_serializer_method(model, '+ attribute', serializer, id_name)     if log?
          serializer.attribute(type_name)
          log_serializer_method(model, '+ attribute', serializer, type_name)   if log?
        end

        def add_polymorphic_method_to_serialzer(model, serializer, assoc_name)
          method_name = assoc_name.to_s + '_type'
          method_name = method_name.to_sym
          unless serializer_has_method?(serializer, method_name)
            serializer.send :define_method, method_name do
              object[method_name].underscore
            end
            log_serializer_method(model, '+ polymorphic method', serializer, method_name) if log?
          end
        end

        # ######################################################################################
        # @!group Authorization and Abilities

        def add_serializer_authorize_has_one(model, serializer, assoc_name, authorize)
          method = :get_totem_authorize_has_one
          serializer.send :define_method, assoc_name do
            self.send(method, assoc_name, authorize)
          end
          log_serializer_method(model, "i [authorize=#{authorize.inspect}] :has_one", nil, assoc_name) if log?
        end

        def add_serializer_authorize_has_many(model, serializer, assoc_name, authorize)
          method = :get_totem_authorize_has_many
          serializer.send :define_method, assoc_name do
            self.send(method, assoc_name, authorize)
          end
          log_serializer_method(model, "i [authorize=#{authorize.inspect}] :has_many", authorize, assoc_name) if log?
        end

        def serializer_authorize_association_method_exists?(model, serializer, assoc_name)
          return false unless serializer_has_method?(serializer, assoc_name)
          log_serializer_method(model, 'o keep_method', serializer, assoc_name) if log?
          warn_message  = "Serializer for model #{model.name.inspect} association method #{assoc_name.inspect} already exists."
          warn_message += "  Assume existing method does authorization."
          warning warn_message
          true
        end

        # ######################################################################################
        # @!group Scoped

        # Implements 'scoped_attributes' in the associations.yml file by defining a serailizer method
        # with the attribute's name that calls the same method on the 'object' (e.g. model instance)
        # passing the serailizer scope (e.g. that contains 'current_user' and 'current_ability').
        #
        # Typical use is setting an attribute value that is scoped to a user association or current ability.
        # The attribute method must be defined on the model or the attribute is skipped.
        #
        def add_scoped_serializer_methods(model, serializer, scoped)
          valid_attrs = Array.new
          scoped.each do |attr|
            # If the method is defined in the model, add a serializer method (of the same name) to call it with the serializer scope
            # unless it is already defined in the serializer.
            if model.method_defined?(attr)
              unless serializer.method_defined?(attr)
                sattr = "__#{attr}__".to_sym # make unique; must match concern active_model_serializer attribute method
                serializer.send :define_method, sattr do
                  object.send(attr, self.scope)
                end
                valid_attrs.push(attr)
              else
                warning "Serializer scoped attribute method [#{attr}] already defined in the serializer for [#{model.name}] -> skipping"
              end
            else
              warning "Serializer scoped attribute method [#{attr}] not defined in model [#{model.name}] -> skipping"
            end
          end
          if valid_attrs.present?
            serializer.attributes(*valid_attrs)
            log_serializer_association(model, :scoped_attributes, serializer, scoped) if log?
          end
        end

        # ######################################################################################
        # @!group Standardize Values

        def standardize_serializer_values(serializer, association, platform_name)
          association = association.symbolize_keys
          if (attrs = association[:attributes]).present?
            association[:attributes] = [attrs].flatten.collect {|a| a.to_sym}
          end
          if (attrs = association[:scoped_attributes]).present?
            association[:scoped_attributes] = [attrs].flatten.collect {|a| a.to_sym}
          end
          association
        end

        def get_json_key_from_assoc(association, assoc_root_name, assoc_name)
          # Solves the issue for has_one/many aliased JSON keys.
          # :has_one, {:root=>"lightbringers/units"}, lightbringers/unit, lightbringers_my_unit
          # ^ Goal is to get a key of lightbringers/my_unit_id
          # :has_many, {:root=>"lightbringers/units"}, lightbringers/units, lightbringers_my_units
          # ^ Goal is to get a key of lightbringers/my_unit_ids

          # Get namespaces and pop off model name.
          namespaces = assoc_root_name.split('/')
          namespaces.pop

          # Formulate an underscored namespace to gsub into assoc_name.
          # Example - the each block results in:
          # => underscored_namespaces = 'lightbringers_'
          # => base_key = 'lightbringers_my_unit'.gsub(underscored_namespace)
          # base_key is then 'my_unit', which is what we want for the key.
          # Add the base_key back to the namespaces array, add appropriate 'id' pluralization, and join back to slashed version:
          # => 'lightbringers/my_unit'
          namespace_string = ''
          namespaces.each { |namespace| namespace_string += (namespace + '_') }
          base_key = assoc_name.to_s.gsub(namespace_string, '') # 'my_unit'

          case
          when association[:has_one]
            namespaces.push(base_key + '_id').join('/')
          when association[:has_many]
            namespaces.push(base_key.singularize + '_ids').join('/')
          end
        end

        def get_json_key(association, assoc_root_name, assoc_name = nil)
          case
          when association[:has_one]
            return get_json_key_from_assoc(association, assoc_root_name, assoc_name) if assoc_name
            association[:embed].present? ? assoc_root_name : assoc_root_name + '_id'
          when association[:has_many]
            return get_json_key_from_assoc(association, assoc_root_name, assoc_name) if assoc_name
            association[:embed].present? ? assoc_root_name : assoc_root_name.singularize + '_ids'
          end
        end

        # ######################################################################################
        # @!group Validation

        def validate_attributes_in_model_table(model, attrs, serializer)
          return unless model.table_exists?  # if running the rake migrate/reset task, the table won't exist yet
          model_columns = model.column_names
          attrs.each do |attr_name|
            next if model_columns.include?(attr_name.to_s) 
            next if serializer.method_defined?(attr_name)
            next if model.method_defined?(attr_name)
            next if active_record_store_attribute?(model, attr_name.to_sym)
            warning "Serializer attribute name [#{attr_name}] not a table column or serializer method for model [#{model.name}]"
          end
        end

        # Note:
        # If include a model's ActiveRecord::Store accessors in the serialier attributes list,
        # the model's "store" call with store accessors (e.g. store :setting, accessors: [:name1, :name2]) 
        # must before the "totem_associations" call inorder to generate the accessor methods to be validated here.
        def active_record_store_attribute?(model, attr_name)
          return false unless model.respond_to?(:stored_attributes)
          return false if model.stored_attributes.blank?
          model.stored_attributes.values.flatten.include?(attr_name)
        end

        def serializer_warnings(model, association, assoc_name)
        end

        # Determine if a 'class' has an instance method for the associations and if the instance method is
        # defined in the base serializer or has been manually overriden.
        def serializer_has_method?(klass, method_name)
          method_name.to_sym  unless method_name.kind_of?(Symbol)
          klass.method_defined?(method_name)
        end

      end
    end
  end
end
