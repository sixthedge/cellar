module Thinkspace; module Authorization; module AbilityClasses

  extend ::ActiveSupport::Concern

  class_methods do

    def require_and_set_ability_classes
      filename = ::Totem::Settings.authorization.platforms.thinkspace.cancan.config_filename
      raise_ability_error "Ability config filename is blank."  if filename.blank?
      filename   += '.yml'  unless filename.end_with?('.yml')
      config_file = ::Rails.root.join('config', 'totem', filename)
      raise_ability_error "Abilities yml file does not exist #{config_file.inspect}."  unless File.exist?(config_file)
      content = File.read(config_file)
      config  = YAML.load(content)
      raise_ability_error "Abilities yml file is invalid (not a hash) #{content.inspect}."  unless config.kind_of?(Hash)
      config      = config.with_indifferent_access
      class_paths = config[:classes]
      raise_ability_error "Abilities yml configuration does not contain a classes section #{config.inspect}."  if class_paths.blank?
      load_ability_classes(class_paths)
    end

    def load_ability_classes(class_paths)
      paths   = class_paths.map {|hash| hash[:path]}.compact
      paths   = File.expand_path('../ability_files', __FILE__)  if paths.blank?  # if packaged, no paths included so are in file folder
      paths   = Array.wrap(paths)
      classes = Array.new
      paths.each do |path|
        files = get_ability_files(path)
        next if files.blank?
        debug_ability_files(path, files)
        files.each do |file|
          filename = File.basename(file, '.rb')
          unless Rails.env.production?
            rc = require_dependency file
            raise_ability_error "Require failed for file #{file.inspect}."  if rc.blank?
          end
          class_name = 'Thinkspace::Authorization::' + filename.camelize
          klass      = class_name.safe_constantize
          raise_ability_error "Ability class #{class_name.inspect} could not be constantized."  if klass.blank?
          raise_ability_error "Duplicate ability class filename #{filename.inspect} in #{file.inspect}."  if classes.include?(klass)
          classes.push(klass)
        end
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
      filenames = files.map {|f| File.basename(f)}.sort.join(', ')
      puts "[debug] Ability classes included in path #{path.inspect} (#{filenames})"
    end

    def startup_quiet?; ::Totem::Settings.config.startup_quiet?; end

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
      set_ability_space_ids
      set_user_role(:user)
      ability_classes.each {|klass| klass.new(self).process}
    end

    def set_user_role(role); @user_role = role; end

  end # included

end; end; end

