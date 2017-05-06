module Totem
  module Core
    module Support
      class Registration

        attr_reader :totem_settings

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :registered_framework_name

        attr_reader :platform_names
        attr_reader :engine_names
        attr_reader :engine_configurations
        attr_reader :all_engine_glob_routes

        def initialize(env)
          @totem_settings         = env
          @platform_names         = []
          @engine_names           = []
          @engine_configurations  = {}
          @all_engine_glob_routes = []
        end

        def register; self; end    # define register
        def registered; self; end  # define registered

        # ######################################################################################
        # @!group Registration

        # register engine name
        def engine(*args)
          options = args.extract_options!
          reset   = options.delete(:reset)
          name    = args.shift
          error "Engine name is blank"  if name.blank?
          error "Engine name is not a string"  unless name.kind_of?(String)
          error "Engine [#{name}] has already been registered"  if engine_names.include?(name)
          # debug "Registering engine [#{name}]"
          engine_names.push(name)
          engine_configurations[name] = options.with_indifferent_access
          unless reset == false # reset support engine.rb to get current engine values
            totem_settings.engine.reset!
            totem_settings.engine.engines_reset!
          end
        end

        # register the framework
        def framework(name=nil, path=nil)
          error "Framework name is blank"  if name.blank?
          error "Framework path is blank"  if path.blank?
          error "Framework name is not a string"  unless name.kind_of?(String)
          error "Framework [#{name}] has already been registered"  if registered_framework_name.present?
          @registered_framework_name = name
          platform(name, path)
        end

        # register a platform name
        def platform(name=nil, path=nil)
          error "Platform name is blank"  if name.blank?
          error "Platform path is blank"  if path.blank?
          error "Platform name is not a string"  unless name.kind_of?(String)
          debug "Registering platform name [#{name}] by engine path [#{path}]"
          error "Platform [#{name}] has already been registered"  if platform_names.include?(name)
          platform_names.push(name)
          totem_settings.defaults.platform_settings(name)
        end

        # array of registered string engine names: ['totem', 'totem_core', ...]
        def engines; engine_names; end

        # registered string framework name
        def framework_name; registered_framework_name; end

        # array of string platform names: ['totem', 'platform', ...]
        def platforms; platform_names; end

        def non_framework_platforms; platform_names - [framework_name]; end

        # assumes only one platform is running
        def platform_name; non_framework_platforms.first; end

        # ######################################################################################
        # @!group Engine Configuration

        # convience methods to get single engine config value
        def engine_platform_name(engine_name);     engine_config_option(engine_name, :platform_name); end
        def engine_platform_path(engine_name);     engine_config_option(engine_name, :platform_path); end
        def engine_platform_scope(engine_name);    engine_config_option(engine_name, :platform_scope); end
        def engine_platform_sub_type(engine_name); engine_config_option(engine_name, :platform_sub_type); end

        # hash of config key values with engine-class-name strings having this value: {key-value: [engine-class-name, ...]}
        def config_value_and_engine_class_names(platform_path, config_key)
          hash = HashWithIndifferentAccess.new
          get_engine_configurations_for_platform_path(platform_path).each_pair do |engine_name, config|
            config_value = engine_config_option(engine_name, config_key.to_sym)
            next if config_value.nil?
            hash[config_value] ||= []
            hash[config_value].push get_engine_class_name_from_engine_name(engine_name)
          end
          hash
        end

        def engine_glob_routes
          all_engine_glob_routes
        end

        def add_engine_glob_route(route_options)
          all_engine_glob_routes.push(route_options)  unless all_engine_glob_routes.include?(route_options)
        end

        private

        def engine_config_option(engine_name, key)
          error "Engine config option engine name is blank"  if engine_name.blank?
          error "Engine config option key for engine name [#{engine_name}] is blank"  if key.blank?
          engine_configurations[engine_name] && engine_configurations[engine_name][key]
        end

        def get_engine_configurations_for_platform_path(platform_path)
          configs = Hash.new
          engine_configurations.each_pair do |engine_name, config|
            engine_path = engine_platform_path(engine_name)
            next if engine_path.blank?
            next unless engine_path.to_s == platform_path.to_s
            configs[engine_name] = config
          end
          configs
        end

        def get_engine_class_name_from_engine_name(engine_name)
          engine_name_and_class = totem_settings.engine.name_and_class
          engine_class = engine_name_and_class[engine_name]
          error "Engine name [#{engine_name}] was not found"  if engine_class.blank?
          engine_class
        end

        include Shared

      end
    end
  end
end
