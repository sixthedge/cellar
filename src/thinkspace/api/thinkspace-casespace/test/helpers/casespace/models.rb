module Test::Casespace::Models
  extend ActiveSupport::Concern

  module ModelClasses
    def user_class;           Thinkspace::Common::User; end
    def space_class;          Thinkspace::Common::Space; end
    def space_user_class;     Thinkspace::Common::SpaceUser; end
    def assignment_class;     Thinkspace::Casespace::Assignment; end
    def phase_class;          Thinkspace::Casespace::Phase; end
    def phase_template_class; Thinkspace::Casespace::PhaseTemplate; end
    def phase_state_class;    Thinkspace::Casespace::PhaseState; end
    def team_class;           Thinkspace::Team::Team; end
    def team_teamable_class;  Thinkspace::Team::TeamTeamable; end
  end

  module ModelSave
    def save_model(model)
      unless model.save
        message  = "\n"
        message += "Error saving build model:\n#{model.inspect}.\nValidation errors: #{model.errors.messages}.\n"
        model.errors.keys.each do |key|
          [model.send(key)].flatten.compact.each do |assoc_model|
            next unless is_active_record?(assoc_model)
            next if assoc_model.errors.blank?
            message += "\n#{assoc_model.inspect}\nValidation errors: #{assoc_model.errors.messages}\n"
          end
        end
        raise message
      end
    end
  end

  module ModelMethods

    # ###
    # ### Model Getters.
    # ###

    def get_username(username)
      user = get_user(username)  # a username string/sym or user instance is ok
      user.first_name && user.first_name.to_sym
    end

    def get_user(username)
      return username if username.is_a?(user_class)
      user = user_class.find_by(first_name: username)
      raise "User name #{username.inspect} not found."  if user.blank?
      user
    end

    def get_users(*args); [args].flatten.compact.map {|u| get_user(u)}; end

    def get_user_by_id(id)
      user = user_class.find_by(id: id)
      raise "User id #{id} not found."  if user.blank?
      user
    end

    def get_user_by_space_role(space, role=:read)
      space_user = space_user_class.find_by(space_id: space.id, role: role)
      raise "Space User in space #{space.id} and role #{role} not found."  if space_user.blank?
      get_user_by_id(space_user.user_id)
    end

    def get_space(title)
      space = space_class.find_by(title: title)
      raise "Space title #{title.inspect} not found."  if space.blank?
      space
    end

    def get_space_user(space, user, role=nil)
      options        = {space_id: space.id, user_id: user.id}
      options[:role] = role  if role.present?
      space_user     = space_user_class.find_by(options)
      raise "Space User #{options.inspect} not found."  if space_user.blank?
      space_user
    end

    def get_assignment(title, options={})
      options.merge!(title: title)
      assignment = assignment_class.find_by(options)
      raise "Assignment title #{title.inspect} options #{options.inspect} not found."  if assignment.blank?
      assignment
    end

    def get_phase(title, options={})
      options.merge!(title: title)
      phase = phase_class.find_by(options)
      raise "Phase title #{title.inspect} options #{options.inspect} not found."  if phase.blank?
      phase
    end

    # ###
    # ### Helpers.
    # ###

    def is_active_record?(model)
      klass = model.is_a?(Class) ? model : model.class
      klass.ancestors.include?(::ActiveRecord::Base)
    end

    # ###
    # ### Associations.
    # ###

    def get_model_association_records_by_class_name(model, class_name)
      assoc_method = get_model_association_method(model, class_name)
      assoc_method.present? ? model.send(assoc_method) : nil
    end

    def get_model_association_method(model, class_name)
      assoc = get_model_association_name(class_name).to_sym
      return assoc if model.respond_to?(assoc)
      assoc = assoc.to_s.pluralize
      return assoc if model.respond_to?(assoc)
      nil
    end

    def get_model_association_name(name); "#{name.underscore.gsub(/\//,'_')}"; end

  end # model methods

  # Models are somewhat unique as the methods may be used at the class level (e.g. model.each loops, seed loads) or
  # at the instance level (e.g. user = get_user(:read_1).
  # 'include Casespace::Models' will add as both class and instance methods.
  class_methods do
    include ModelClasses
    include ModelSave
    include ModelMethods
  end

  included do
    include ModelClasses
    include ModelSave
    include ModelMethods
  end
end
