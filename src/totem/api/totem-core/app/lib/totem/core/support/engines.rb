module Totem
  module Core
    module Support
      class Engines

        attr_reader :totem_settings

        attr_reader :engine_instances

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :engine_names
        attr_reader :engine_name_and_class
        attr_reader :engine_name_and_engine
        attr_reader :engine_path_and_name
        attr_reader :engine_association_paths

        def initialize(env)
          @totem_settings  = env
        end

        # define engine.
        def engine; self; end

        # array of totem engine instances
        def engines
          @engine_instances ||= ::Rails::Engine.subclasses.map(&:instance).select {|e| is_registered_platform_engine?(e)}
        end

        def is_registered_platform_engine?(e)
          return false unless e.respond_to?(:engine_name)
          totem_settings.registered.engines.include?(e.engine_name)
        end

        # ######################################################################################
        # @!group Engine Information

        # array of string engine names (engine_name setting): ['totem_core', 'totem_authentication', ...]
        def names
          @engine_names ||= engines.collect {|e| engine_name(e)}
          engine_names.dup
        end

        # hash of string engine name with engine instance; used in adding routes
        def name_and_engine
          @engine_name_and_engine ||= Hash[*engines.collect {|e| [engine_name(e), e]}.flatten]
        end

        # hash of engine_name: engine_class: 'totem_core' => 'Totem::Core', ...; used by engine validation
        def name_and_class
          @engine_name_and_class ||= Hash[*engines.collect { |e| [engine_name(e), engine_class_name(e)] }.flatten]
          engine_name_and_class.dup
        end

        # hash of engine paths and engine names: 'totem/authentication/user' => totem_authentication_user ...
        def path_and_name
          @engine_path_and_name ||= Hash[*engines.collect { |e| [engine_class_name(e).underscore, engine_name(e)] }.flatten]
          engine_path_and_name.dup
        end

        # array of engine association.yml file paths (full paths)
        def association_paths
          @engine_association_paths ||= get_model_association_paths
          engine_association_paths.dup
        end

        # force instance variables to be re-populated from current engines array on next request.
        def reset!
          @engine_names             = nil
          @engine_name_and_engine   = nil
          @engine_name_and_class    = nil
          @engine_path_and_name     = nil
          @engine_association_paths = nil
        end

        # force engines instances to be re-populated on next request.
        def engines_reset!
          @engine_instances = nil
        end

        # ######################################################################################
        # @!group Public Engine Helpers

        # engine name from the engine instance
        def engine_name(e)
          e.engine_name
        end

        # engine class name from the engine instance
        def engine_class_name(e)
          e.class.name.deconstantize  # remove the ::Engine part
        end

        # engine is loaded
        def loaded?(name)
          names.include?(name)
        end

        # convert engine class, path to engine name
        def to_engine_name(name)
          return nil unless name.instance_of?(String)
          name.underscore.gsub(/\//, '_')
        end

        # ######################################################################################
        # @!group Engine Finders

        # array of engine 'instances' matching the name (should only be one)
        def get_by_name(name)
          engines.select {|e| engine_name(e) == name}
        end

        # array of engine 'names' matching name
        def find_by_name(name)
          return nil unless name.present?
          names.select {|e| e == name}
        end

        # array of engine 'names' starting with name; used by wildcard matches
        def find_by_starts_with(name)
          return nil unless name.present?
          names.select {|e| e.starts_with?(name)}
        end

        # ######################################################################################
        # @!group Current Engine and Conversions

        # To get the current platform name, first get the 'engine name' from the table_name_prefix
        # class method, then lookup the engine's registered platform name.
        # Note: If the engine is not registered, will return nil.
        def current_platform_name(object)
          klass = object.kind_of?(Class) ? object : object.class
          name  = get_table_name_prefix(klass)
          name  = name.dup.chop
          totem_settings.registered.engine_platform_name(name)
        end

        # If platform name is set in a module method 'totem_platform_name' rather than engine option.
        # def current_platform_name(object)
        #   klass = object.kind_of?(Class) ? object : object.class
        #   (klass.parents.detect{ |p| p.respond_to?(:totem_platform_name) } || self).totem_platform_name
        # end

        private

        # ######################################################################################
        # @!group Helper Methods

        def get_table_name_prefix(klass)
          (klass.parents.detect{ |p| p.respond_to?(:table_name_prefix) } || self).table_name_prefix
        end

        def get_railtie_namespace(klass)
          (klass.parents.detect{ |p| p.respond_to?(:table_name_prefix) } || self).railtie_namespace
        end

        def get_model_association_paths
          file_name  = totem_settings.option.db_associations_filename
          error "The associations file name is blank."  if file_name.blank?
          file_paths = []
          engines.each do |engine|
            db_paths = engine.config.paths['db']
            db_paths.each do |path|
              db_path    = Pathname.new(File.join(engine.root, path))
              assoc_file = File.join(db_path, file_name)
              if File.exists?(assoc_file)
                file_paths.push assoc_file
              end
            end
          end
          file_paths.flatten.compact
        end

        include Shared

      end
    end
  end
end