module Test::Casespace::RouteModels
  extend ActiveSupport::Concern

  included do

    def set_new_model_dictionary_for_route_request(model_class, options={})
      base_classes  = get_base_model_classes(model_class)
      assoc_classes = get_association_classes_for_base_classes(model_class, base_classes)
      dictionary    = Hash.new
      get_let_models.each {|m| dictionary[m.class] = m}
      base_classes.each  {|c| dictionary[c] = c.new  unless dictionary.has_key?(c)}
      assoc_classes.each {|c| dictionary[c] = c.new  unless dictionary.has_key?(c)}
      add_model_values_and_associations(dictionary)
      model = dictionary[model_class]
      @route.set_model(model)
      @route.before_save(dictionary, options)  # allow controller specfic changes to the dictionary (sets the dictionary in the route)
      save_dictionary_models(dictionary, base_classes.reverse)
      save_dictionary_models(dictionary, dictionary.keys)  # save all new records e.g. assoc models +/- any changes by helpers
    end

    def save_dictionary_models(dictionary, model_classes)
      model_classes.each do |klass|
        model = dictionary[klass]
        next unless model.new_record?
        save_model(model)
      end
    end

    # ###
    # ### Model Classes to Build.
    # ###

    def delegateable_assocations; [:authable, :ownerable]; end

    def get_base_model_classes(model_class, base_classes=[])
      add_build_model_class(base_classes, model_class)
      raise "Error finding build model classes for #{base_classes.first.inspect}.  Over max depth 5."  if base_classes.length >= 5    # incase code bug in recursive calls
      # Add any delegateable model classes.
      delegateable_assocations.each do |name|
        next if model_class_has_association?(model_class, name)  # model has the association e.g. not delegated
        if model_class_has_method?(model_class, name)
          klass = get_next_model_class_for_association_name(model_class, name)
          if klass.present? && !base_classes.include?(klass)  # prevent self referencing delegates
            add_build_model_class(base_classes, klass)
            get_base_model_classes(klass, base_classes)  unless model_class_has_association?(klass, name)
          end
        end
      end
      base_classes
    end

    def get_next_model_class_for_association_name(model_class, name)
      return model_class if model_class_has_association?(model_class, name)
      get_all_associations(model_class).each do |assoc|
        klass = get_association_model_class(assoc)
        return klass if klass.present? && (model_class_has_association?(klass, name) || model_class_has_method?(klass, name))
      end
      nil
    end

    def get_association_classes_for_base_classes(model_class, base_classes, assoc_classes=[], do_classes=[])
      raise "Error finding build classes associations.  Over max depth 15."  if assoc_classes.length >= 15  # incase code bug in recursive calls
      classes = Array.new
      (do_classes.present? ? do_classes : base_classes).each do |base_class|
        get_all_associations(base_class).each do |assoc|
          next if is_through_association?(assoc)
          name = get_association_name(assoc)
          next if delegateable_assocations.include?(name)
          klass = get_association_model_class(assoc)
          next if klass.blank?
          next unless model_classes_in_same_namespace?(model_class, klass)
          next if base_classes.include?(klass)
          next if assoc_classes.include?(klass)
          classes.push(klass)
          add_build_model_class(assoc_classes, klass)
        end
        if classes.present?
          get_association_classes_for_base_classes(model_class, base_classes, assoc_classes, classes)
        end
      end
      assoc_classes.uniq
    end

    def add_build_model_class(classes, model_class); classes.push(model_class)  unless classes.include?(model_class); end

    # ###
    # ### Add Model Values and Associations.
    # ###

    def add_model_values_and_associations(dictionary)
      dictionary.keys.each do |model_class|
        model = dictionary[model_class]
        next unless model.new_record?
        perform_common_model_values(model)
        get_all_associations(model_class).each do |assoc|
          name = get_association_name(assoc)
          case
          when name == :authable
            set_model_authable(model)
          when name == :ownerable
            set_model_ownerable(model)
          when is_polymorphic_association?(assoc)
            set_polymorphic_model(model, name)
          else
            next if is_through_association?(assoc)
            klass = get_association_model_class(assoc)
            next if klass.blank?
            assoc_model = dictionary[klass]
            if assoc_model.present?
              if is_has_many?(model_class, name)
                model.send "#{name}=", [assoc_model]
              else
                model.send "#{name}=", assoc_model
              end
            else
              next unless model_classes_in_same_namespace?(model_class, klass)
              new_model = klass.new
              perform_common_model_values(new_model)
              set_model_authable(new_model)
              set_model_ownerable(new_model)
              poly_assocs = get_belongs_to_associations(klass).select {|a| is_polymorphic_association?(a)}
              poly_names  = poly_assocs.map {|a| get_association_name(a)} - [:authable, :ownerable]
              poly_names.each do |name|
                set_polymorphic_model(new_model, name)
              end
              name = get_model_association_method(new_model, model_class.name)
              if is_has_many?(klass, name)
                new_model.send "#{name}=", [model]
              else
                new_model.send "#{name}=", model
              end
              dictionary[klass] = new_model
            end
          end
        end
      end
    end

    def perform_common_model_values(model)
      set_model_test_values(model)
      set_model_email(model)
      set_model_user_id(model)
      stub_model_callbacks(model)
    end

    def set_model_test_values(model)
      ignore_string_columns = [:state, :current_state]
      model.class.columns.each do |column|
        name  = column.name.to_sym
        value = nil
        case
        when column.type == :string
          next if ignore_string_columns.include?(name)
          next if name.to_s.end_with?('_type') && is_polymorphic?(model.class, name.to_s.sub(/_type$/,''))
          value = Time.now.to_s + model.object_id.to_s
        when column.type == :datetime
          next if [:created_at, :updated_at].include?(name)
          value = Time.now
        else
          next
        end
        model.send "#{name}=", value
      end
    end

    def stub_model_callbacks(model)
      model.class.send(:get_callbacks, :create).each do |callback|
        method = callback.instance_variable_get(:@key)
        next if method.blank? || method.is_a?(Fixnum)
        model.define_singleton_method method do; return; end
      end
    end

    def set_model_authable(model)
      return unless model_class_has_association?(model.class, :authable)
      case
      when model.is_a?(team_class)
        authable = find_model_in_let_models(space_class) || get_let_value(:authable)
      else
        authable = get_let_value(:authable) || find_model_in_let_models(phase_class)
      end
      model.authable = authable
    end

    def set_model_ownerable(model)
      return unless model_class_has_association?(model.class, :ownerable)
      ownerable = get_let_value(:ownerable) || find_model_in_let_models(user_class) || get_let_value(:user)
      model.ownerable = ownerable
    end

    def set_polymorphic_model(model, name)
      poly_model = find_model_in_let_models(phase_class) || get_let_value(:authable)
      model.send "#{name}=", poly_model
    end

    def set_model_email(model)
      return unless model_class_has_column?(model.class, :email)
      user = get_let_value(:user)
      model.email = user && user.email
    end

    def set_model_user_id(model)
      return unless model_class_has_column?(model.class, :user_id)
      user = get_let_value(:user)
      model.user_id = user && user.id
    end

    # ###
    # ### Helpers.
    # ###

    def get_association_model_class(assoc)
      class_name = get_association_class_name(assoc)
      class_name && class_name.safe_constantize
    end

    def get_let_models; get_let_value_array(:models); end
    def find_model_in_let_models(model_class); get_let_models.find {|m| m.is_a?(model_class)}; end

    def model_classes_in_same_namespace?(model1, model2)
      return false if model1.blank? || model2.blank?
      model1.name.deconstantize == model2.name.deconstantize
    end

    def get_association_name(assoc);        assoc && assoc.name; end
    def get_association_class_name(assoc);  assoc && assoc.options[:class_name]; end
    def get_association_foreign_key(assoc); assoc && assoc.options[:foreign_key]; end
    def is_through_association?(assoc);     assoc && assoc.options[:through].present?; end
    def is_polymorphic_association?(assoc); assoc && assoc.options[:polymorphic].present?; end

    def is_has_many?(model_class, name)
      assoc = model_class_association(model_class, name)
      assoc && assoc.macro == :has_many
    end

    def is_polymorphic?(model_class, name); name && is_polymorphic_association?(model_class.reflect_on_association(name.to_sym)); end

    def get_belongs_to_associations(model_class);        model_class.reflect_on_all_associations(:belongs_to); end
    def get_all_associations(model_class);               model_class.reflect_on_all_associations; end
    def model_class_association(model_class, name);      name   && model_class.reflect_on_association(name.to_sym); end
    def model_class_has_association?(model_class, name); name   && model_class_association(model_class, name).present?; end
    def model_class_has_method?(model_class, method);    method && model_class.method_defined?(method); end
    def model_class_has_column?(model_class, column);    column && model_class.column_names.include?(column.to_s); end

  end # included
end
