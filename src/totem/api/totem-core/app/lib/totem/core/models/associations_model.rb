module Totem
  module Core
    module Models
      module AssociationsModel

        # ######################################################################################
        # @!group Model Association Detail

        def add_model_association(model, association, options)
          association = association.symbolize_keys

          # remove non-Rails keys and keys that provide information or need special processing
          assoc_name      = association.delete(:name)
          nested_attr_for = association.delete(:accepts_nested_attributes_for)
          scope           = association.delete(:scope)
          readonly        = association.delete(:readonly)

          scope_string = get_scope_string(scope, readonly)
          scope        = get_scope_lambda(scope_string)
          assoc_class  = nil

          valid_class = association.delete(:valid_class)
          return warning "Invalid class for model [#{model}] and association [#{association.inspect}], skipping so any reference will result in an error." unless valid_class

          # Include any common platform modules in the model.
          include_model_modules(model, assoc_name, association)
          # Validate authable type/id are present.
          add_authable_after_save(model, assoc_name, association)

          case

          when assoc_class = association.delete(:belongs_to)
            association[:class_name] = assoc_class  unless is_polymorphic?(association)
            set_foreign_key(model, association, :belongs_to)
            log_model_association_type(:belongs_to, model, association, name: assoc_name, scope: scope_string)  if log?
            model.belongs_to(assoc_name, scope, association)

          when assoc_class = association.delete(:has_one)
            association[:class_name] = assoc_class
            set_foreign_key(model, association, :has_one)
            log_model_association_type(:has_one, model, association, name: assoc_name, scope: scope_string)  if log?
            model.has_one(assoc_name, scope, association)

          when assoc_class = association.delete(:has_many)
            association[:class_name] = assoc_class
            set_foreign_key(model, association,:has_many)
            log_model_association_type(:has_many, model, association, name: assoc_name, scope: scope_string)  if log?
            model.has_many(assoc_name, scope, association)

          else
            error "Class [#{model.name}] has unknown association [#{association.inspect}]"

          end

          if nested_attr_for.present? && assoc_class.present?
            assoc_name      = plural_association_name(assoc_class)
            nested_attr_for = nested_attr_for.symbolize_keys
            model.accepts_nested_attributes_for(assoc_name, nested_attr_for)
            log_model_association(model, 'accepts_nested_attributes_for', assoc_name, nested_attr_for) if log?
          end

        end

        def get_scope_lambda(scope_string)
          return nil if scope_string.blank?
          eval "lambda { #{scope_string} }"
        end

        def get_scope_string(scope, readonly)
          case 
          when scope.present? && readonly.present?
            scope.strip + '.readonly'
          when scope.blank? && readonly.present?
            'readonly'
          when scope.present? && readonly.blank?
            scope.strip
          else
            ''
          end
        end

        def set_foreign_key(model, association, type)
          unless as_polymorphic?(association) || is_polymorphic?(association)
            unless association[:foreign_key]
              case type
              when :belongs_to
                assoc_class = association[:class_name]
                association[:foreign_key] = assoc_class.foreign_key
              when :has_one
                association[:foreign_key] = model.name.foreign_key
              when :has_many
                association[:foreign_key] = model.name.foreign_key
              end
            end
          end
        end

        # For new nested records, the deep_cloneable gem adds associations with nil ids
        # for the root record that are resolved when the root record is saved.
        # However, a standard Rails model validation in the nested record for 'authable_id presence'
        # will fail since the authable_id is nil. This block will validate the authable is present after saving
        # the record.  Nested records require the use of 'validates_associated' so the root
        # record will recieve the nested validation errors when saved.
        def add_authable_after_save(model, assoc_name, association)
          case 
          when assoc_name == :authable && is_polymorphic?(association)
            model.after_save do
              (self.authable_type.present? && self.authable_id.present?) ? true : false
            end
          end
        end

        # Include additional model modules based on the association.
        # e.g. add scope_by_ownerables to models with :ownerable association.
        def include_model_modules(model, assoc_name, association)
          case 
          when assoc_name == :ownerable && is_polymorphic?(association)
            include_model_module(model, :scope_by_ownerables)
          end
        end

        def include_model_module(model, mod_name)
          platform_name = totem_settings.engine.current_platform_name(model)
          mods          = ::Totem::Settings.module[platform_name]
          return if mods.blank?
          mod = mods.has_module?(mod_name) ? mods.get_module(mod_name) : nil
          model.send(:include, mod)
        end

       def log_model_association_type(type, model, association, log_options={})
          assoc_name  = log_options.delete(:name)
          log_options.delete(:scope) if log_options[:scope].blank?
          log_options = log_options.merge(association)
          log_model_association(model, type, assoc_name, log_options)
       end

      end
    end
  end
end
