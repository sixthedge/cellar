module Thinkspace; module Authorization; module AbilityClasses

  extend ::ActiveSupport::Concern

  class_methods do

    def require_and_set_ability_classes
      path = Rails.root.join('config/totem/ability_files').to_s
      raise_ability_error "Authorization ability files path #{path.inspect} is not a directory."  unless File.directory?(path)
      classes = Array.new
      files   = get_ability_files(path)
      raise_ability_error "Authorization ability files are blank in path #{path.inspect}."  if files.blank?
      debug_ability_files(path, files)
      files.each do |file|
        filename = File.basename(file, '.rb')
        rc = require_dependency file
        raise_ability_error "Require failed for file #{file.inspect}."  if rc.blank? && !Rails.env.production?
        class_name = 'Thinkspace::Authorization::' + filename.camelize
        klass      = class_name.safe_constantize
        raise_ability_error "Ability class #{class_name.inspect} could not be constantized."  if klass.blank?
        raise_ability_error "Duplicate ability class filename #{filename.inspect} in #{file.inspect}."  if classes.include?(klass)
        classes.push(klass)
      end
      self.ability_classes = classes
    end

    def get_ability_files(root_path)
      return nil if root_path.blank?
      pattern = File.join(root_path, '**/*.rb')
      Dir.glob(pattern)
    end

    def debug_ability_files(path, files)
      return if startup_quiet?
      filenames = files.map {|f| File.basename(f)}.sort
      debug_ability_message "[debug] Ability classes (#{filenames.length}) included in path #{path.inspect}"
      filenames.each_with_index do |filename, index|
        debug_ability_message "[debug]   #{(index+1).to_s.rjust(3)}. #{filename}"
      end
    end

    def startup_quiet?; ::Totem::Settings.config.startup_quiet?; end

    def debug_ability_message(message)
      # puts message
      Rails.logger.debug message
    end

    def raise_ability_error(message=''); puts "\n"; raise "#{self.name}: #{message}"; end

  end

  included do
    cattr_accessor :ability_classes
    require_and_set_ability_classes

    attr_reader :user, :user_role

    def set_abilities(user)
      return nil if user.blank?
      @user = user
      set_read_alias_actions
      set_crud_alias_actions
      set_ability_institution_ids
      set_ability_space_ids
      set_user_role(:user)
      ability_classes.each {|klass| klass.new(self).process}
    end

    def set_user_role(role); @user_role = role; end

  end # included

end; end; end
