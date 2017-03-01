module Totem
  module Core
    module Models
      module Definitions

        # Iterate over the definitions and change the yml model file paths to class names.
        # Performs this for the model, associations and serializer values.
        def resolve_model_definition_classes_and_values(model_definitions=get_model_definitions)
          return nil if model_definitions.blank?
          @all_model_definitions = model_definitions
          model_definitions.each do |model_definition|
            model_definition[:model_path] = model_definition[:model].to_s  # save the original paths
          end
          model_definitions.each do |model_definition|
            model_definition[:model] = resolve_model_path_to_class(model_definition, get_model(model_definition))
            resolve_model_definition_association_classes_and_values(model_definition)
            resolve_model_definition_serializer_classes_and_values(model_definition)
          end
        end

        # Read the association files (db/associations.yml) and return the combined defintions.
        # Returns an array of the model hashes: [ {model-path: options-hash}, ...  ]
        def get_model_definitions
          model_definitions = []
          association_paths = totem_settings.engine.association_paths || []
          association_paths.each do |path|
            yaml_file          = File.read(path)
            model_associations = YAML.load(yaml_file)
            error "Model associations file [#{path}] does not exist or is empty"  if model_associations.blank?
            error "Model associations file [#{path}] is not a valid format (is not an array)"  unless model_associations.kind_of?(Array)
            model_associations.each do |association|
              error "Model association [#{association.inspect}] in file [#{path}] is not a valid format (is not a hash)"  unless association.kind_of?(Hash)
              model_definitions.push HashWithIndifferentAccess.new(association)
            end
          end
          model_definitions
        end

        # Return the model definition for a model.
        def find_model_definition(model_definitions, model_name)
          model_definitions.each do |mdef|
            def_model = get_model(mdef)
            return mdef.deep_dup if def_model == model_name
          end
          nil
        end

        # Return the individual association portion of the model definition for a model.
        # Matches on the model association name e.g. platform_tools_html_content.
        def find_model_definition_association(model_definitions, model_name, assoc_name)
          model_definition = find_model_definition(model_definitions, model_name)
          return nil if model_definition.blank?
          assoc_name_sym = assoc_name.to_sym
          get_model_definition_associations(model_definition).each do |association|
            return association if association[:name] == assoc_name_sym
          end
          nil
        end

        # Return the seriliazer portion (:has_one or :has_many) of the model definition for a model.
        # Matches on the seralizer association class (e.g. not the association name).
        def find_model_definition_serializer_class_association(model_definitions, model_name, assoc_class)
          model_definition = find_model_definition(model_definitions, model_name)
          return nil if model_definition.blank?
          get_model_definition_serializers(model_definition).each do |serializer|
            serializer.each do |association|
              klass = association[:has_one] || association[:has_many]
              return association if klass == assoc_class
            end
          end
          nil
        end

        # ######################################################################################
        # @!group Resolve

        def resolve_model_definition_association_classes_and_values(model_definition)
          associations = get_model_definition_associations(model_definition)
          associations.each do |association|
            error_in_def(model_definition, "Requires a foreign key because it has an alias.  Foreign key is not present.") if association[:alias].present? and !is_foreign_keyed?(association)
            assoc_class = nil
            case
            when (assoc_name = association[:belongs_to]).present?
              # Validity of model checks to determine whether or not the engine was loaded.
              valid_class                             = valid_association_class?(assoc_name, association)
              valid_class ? association[:valid_class] = true : association[:valid_class] = false
              next unless valid_class

              assoc_class               = resolve_model_path_to_class(model_definition, assoc_name, association)
              association[:belongs_to]  = assoc_class
              association[:name]        = singular_association_name(assoc_class, association)
            when (assoc_name = association[:has_one]).present?
              # Validity of model checks to determine whether or not the engine was loaded.
              valid_class                             = valid_association_class?(assoc_name, association)
              valid_class ? association[:valid_class] = true : association[:valid_class] = false
              next unless valid_class

              assoc_class               = resolve_model_path_to_class(model_definition, assoc_name, association)
              association[:has_one]     = assoc_class
              association[:name]        = singular_association_name(assoc_class, association)
            when (assoc_name = association[:has_many]).present?
              # Validity of model checks to determine whether or not the engine was loaded.
              valid_class                             = valid_association_class?(assoc_name, association)
              valid_class ? association[:valid_class] = true : association[:valid_class] = false
              next unless valid_class

              assoc_class            = resolve_model_path_to_class(model_definition, assoc_name, association)
              association[:has_many] = assoc_class
              association[:name]     = plural_association_name(assoc_class, association)
            else
              error_in_def(model_definition, "Unknown model association type #{association.inspect}")
            end
            if (source_name = association[:source])
              source_type  = association[:source_type]
              source_class = source_type || resolve_model_path_to_class(model_definition, source_name, association)
              if source_type.blank? 
                association[:source]   = source_name == source_name.singularize ? singular_association_name(source_class) : plural_association_name(source_class)
              end
            end
            if (through_name = association[:through])
              through_class = resolve_model_path_to_class(model_definition, through_name, association)
              association[:through] = through_name == through_name.singularize ? singular_association_name(through_class) : plural_association_name(through_class)
              unless association[:source].present?
                association[:source] = singular_association_name(assoc_class)
              end
            end
          end
        end

        def resolve_model_definition_serializer_classes_and_values(model_definition)
          serializers = get_model_definition_serializers(model_definition)
          serializers.each do |serializer|
            serializer.each do |association|
              case
              when (assoc_name = association[:has_one]).present?
                # Validity of model checks to determine whether or not the engine was loaded.
                valid_class                             = valid_association_class?(assoc_name, association)
                valid_class ? association[:valid_class] = true : association[:valid_class] = false
                next unless valid_class

                assoc_class             = resolve_model_path_to_class(model_definition, assoc_name, association)
                association[:has_one]   = assoc_class
                association[:name]      = singular_association_name(assoc_class, association)
              when (assoc_name = association[:has_many]).present?
                # Validity of model checks to determine whether or not the engine was loaded.
                valid_class                             = valid_association_class?(assoc_name, association)
                valid_class ? association[:valid_class] = true : association[:valid_class] = false
                next unless valid_class

                assoc_class             = resolve_model_path_to_class(model_definition, assoc_name, association)
                association[:has_many]  = assoc_class
                association[:name]      = plural_association_name(assoc_class, association)
              when (assoc_name = association[:attribute])
                # Validity of model checks to determine whether or not the engine was loaded.
                valid_class                             = valid_association_class?(assoc_name, association)
                valid_class ? association[:valid_class] = true : association[:valid_class] = false
                next unless valid_class

                assoc_class             = resolve_model_path_to_class(model_definition, assoc_name, association)
                association[:attribute] = assoc_class
              end
            end
          end
        end

        def resolve_model_path_to_class(model_definition, model_path, association={})
          error_in_def(model_definition, "Cannot resolve blank model path")  if model_path.blank?
          model_path  = model_path.to_s
          return model_path if is_polymorphic?(association)  # polymorphics use a type column for the class, not the association
          validate_path_and_access(model_definition, model_path, association)
          model_path.classify
        end

        def validate_path_and_access(model_definition, model_path, association)
          model             = get_model(model_definition) || ''
          model_engine_name = get_model_engine_name(model, model_definition)
          model_scope       = get_engine_platform_scope(model_engine_name)
          assoc_engine_name = get_model_engine_name(model_path, model_definition)
          assoc_scope       = get_engine_platform_scope(assoc_engine_name)
          model_definition[:engine_name] = model_engine_name
          return unless model == model.classify  # return if resolving a model name (e.g. not an association)
          return if assoc_scope == model_scope   # same scope so ok

          assoc_platform_name = get_engine_platform_name(assoc_engine_name)
          allowed_access      = totem_settings.config.model_access(assoc_platform_name) || {}
          path_for_access     = model_path.singularize
          path_access         = allowed_access[path_for_access] || []
          error_in_def(model_definition,
            message: "Association scope [#{assoc_scope}] not within access scope [#{model_scope}] and no model access defined.",
            association:     association,
            path_for_access: path_for_access,
            allowed_access:  allowed_access,
          )  if path_access.blank?
          validate_model_access(model_definition, association, model_path, path_access)
        end

        def get_model_engine_name(path, model_definition)
          engine_path          = path.classify.deconstantize.underscore
          engine_path_and_name = totem_settings.engine.path_and_name || {}
          engine_name          = engine_path_and_name[get_engine_model_path(engine_path, model_definition)]
          if engine_name.blank?  # if still blank may be an association to a namespaced model within an engine
            assoc_def = @all_model_definitions.select {|m| m[:model_path] == path || m[:model_path] == path.singularize}
            if assoc_def.present? && assoc_def.length == 1
              engine_name = engine_path_and_name[get_engine_model_path(engine_path, assoc_def.first)]
            end
          end
          warning "Could not determine engine name for path [#{path}] in model [#{model_definition}]"  if engine_name.blank?
          engine_name
        end

        def get_engine_model_path(path, model_definition)
          namespace = model_definition[:namespace]
          namespace.present? ? path.sub(/\/#{namespace}$/,'') : path
        end

        def get_engine_platform_name(engine_name)
          platform_name = totem_settings.registered.engine_platform_name(engine_name)
          error "Could not determine platform name for engine name [#{engine_name}]"  if platform_name.blank?
          platform_name
        end

        def get_engine_platform_scope(engine_name)
          platform_scope = totem_settings.registered.engine_platform_scope(engine_name)
          error "Could not determine platform scope for engine name [#{engine_name}]"  if platform_scope.blank?
          platform_scope
        end

        # model_definition:  model's full association definition
        # model association: model's association being validated (e.g. belongs_to, has_many, etc.)
        # path:              the association path to check if the access is allowed from the model
        # path_access:       access hash for the association path that is allowed by the framework config
        def validate_model_access(model_definition, association, path, path_access)
          model = get_model(model_definition).underscore
          path_access.each do |access|
            error_in_def(model_definition, "Framework model_access [#{access}] for path [#{path}] is not a hash")  unless access.kind_of?(Hash)
            access_model = access[:model]
            error_in_def(model_definition, "Model [#{model}] access does not have a model value")  if access_model.blank?
            #
            # if the specific model is included in access list, verify restictions and return
            return validate_restrictions(model_definition, model, association, access)  if model == access_model
            #
            # if framework access allows any model access, verify restrictions and return
            return validate_restrictions(model_definition, model, association, access)  if access_model == '*'  # matches all
            #
            next unless access_model.ends_with?('*')
            starts_with_access = access_model.sub(/\*$/,'')
            #
            # if the model mataches a wildcard framework access; verify restrictions and return
            return validate_restrictions(model_definition, model, association, access)  if model.starts_with?(starts_with_access)  # matches starting path
          end
          error_in_def(model_definition,
            message:     "Model [#{model}] association [#{path}] not allowed.",
            association: association,
            path:        path,
            path_access: path_access,
          )
        end

        # association: the model's association being validated
        # access:      the framework's model access allowed
        def validate_restrictions(model_definition, model, association, access)
          restrictions = [ access['restrictions'] ].flatten.compact
          if restrictions.include?('readonly') && !association['readonly']
            return if not model_definition[:associations].include?(association) # This association is from the serializer, not the model.
            error_in_def(model_definition, "Model [#{model}] association must be readonly [#{association.inspect}]")
          end
        end

        # ######################################################################################
        # @!group Utility

        def embed?(association)
          association[:embed] == :objects
        end

        def get_model(model_definition)
          model_definition[:model]
        end

        def get_model_definition_associations(model_definition)
          model_definition[:associations] || []
        end

        # Serializer structure:
        #   model_definition[:serializers] = array of hashes
        #   within the array of hashes may be hashes with: {serializer: serializer values}
        def get_model_definition_serializers(model_definition)
          serializers_array = []
          if (serializers = model_definition[:serializers])
             serializers.each do |hash|
               serializers_array.push(hash[:serializer])  if hash.has_key?(:serializer)
             end
          end
          serializers_array
        end

        def singular_association_name(klass, association={})
          class_name = get_association_name(klass, association)
          class_name.underscore.singularize.gsub('/','_').to_sym
        end

        def plural_association_name(klass, association={})
          class_name = get_association_name(klass, association)
          class_name.underscore.pluralize.gsub('/','_').to_sym
        end

        def get_association_name(klass, association)
          alias_name = association.delete(:alias)
          return alias_name.to_s if alias_name.present? && is_polymorphic?(association)
          alias_name.present? ? klass.deconstantize + "::#{alias_name}" : klass
        end

        def is_polymorphic?(association)
          association[:polymorphic] == true
        end

        def as_polymorphic?(association)
          association[:as].present?
        end

        def is_foreign_keyed?(association)
          association[:foreign_key].present?
        end

        def is_class_named?(association)
          association[:class_name].present?
        end

        def is_foreign_belongs_to?(association)
          is_foreign_keyed?(association) && is_class_named?(association)
        end

        def valid_association_class?(name, association)
          return true if is_polymorphic?(association)
          klass = name.to_s.classify.safe_constantize
          klass ? true : false
        end

        def error_in_def(model_definition, error_message)
          mdef = model_definition || {}
          if error_message.kind_of?(Hash)
            message = error_message.delete(:message) || ''
            error_message.each_pair do |key, value|
              value_string = value 
              message += "\n#{key.inspect}:\n#{value.to_yaml}"
            end
          else
            message = error_message || ''
          end
          message += "\nModel_definition:\n#{model_definition.to_yaml}"
          error message
        end

      end
    end
  end
end

