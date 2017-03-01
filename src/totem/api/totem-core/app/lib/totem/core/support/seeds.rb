module Totem
  module Core
    module Support
        class Seeds

        attr_reader :totem_settings

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :seed_order_platform
        attr_reader :seed_order_all

        def initialize(env)
          @totem_settings = env
        end

        # ######################################################################################
        # @!group Public

        # define seed.
        def seed; self; end

        # array of engine 'names' by seed order
        def order(platform_name)
          @seed_order_platform ||= get_platform_seed_order(platform_name)
        end

        def order_all
          @seed_order_all ||= get_all_platforms_seed_order
        end

        # instance of seed loader
        def loader(*args)
          SeedLoader.new(*args)
        end

        private

        # ######################################################################################
        # @!group Seed Order ALL
        def get_all_platforms_seed_order
          seed_order = Array.new
          platforms  = totem_settings.config.platforms
          error "No platforms defined to seed."  if platforms.blank?
          framework_name = totem_settings.registered.framework_name
          error "Framework is not registered."  if framework_name.blank?
          framework_seed_order = get_platform_seed_order(framework_name)
          seed_order          += framework_seed_order
          platforms.keys.sort.each do |platform_name|
            name = platform_name.to_s
            next if name == framework_name  # already added the framework seed order first
            seed_order += get_platform_seed_order(name)
          end
          seed_order.uniq
        end

        # ######################################################################################
        # @!group Seed Order

        # Seed orders can be defined in a platform's 'seed_order' section or will 
        # default to the order listed in the 'platform' section.
        def get_platform_seed_order(platform_name)
          seed_order        = Array.new
          config_seed_order = totem_settings.config.seed_order(platform_name)  # seed_order section
          if config_seed_order.kind_of?(Array) && config_seed_order.blank?
            # If the seed order is a blank array assume means no seed order
            # versus if nil, means ignore seed_order key and use platform.
            info "Platform name [#{platform_name}] seed order is blank"
            return seed_order
          end
          if config_seed_order.present?
            information_message platform_name, :seed_order
            get_seed_order_from_config(config_seed_order)
          else
            information_message platform_name, :paths
            get_seed_order_from_platform_paths(platform_name)
          end
        end

        # Seed order from 'paths' section.
        def get_seed_order_from_platform_paths(platform_name)
          seed_order = Array.new
          paths      = totem_settings.config.paths(platform_name)
          error "No seed order is defined for platform [#{platform_name.inspect}]"  if paths.blank?
          paths.each do |path_config|
            next unless path_config.is_engine  # if not an engine, nothing to seed
            seed_order.push path_config.engine_name
          end
          seed_order
        end

        # Seed order from 'seed_order' section.
        def get_seed_order_from_config(config_seed_order)
          seed_order   = Array.new
          all_paths = shared_expand_wildcard_engine_paths(config_seed_order)  # expand any wildcard paths
          all_paths.each do |path|
            if engine_path_loaded?(path)
              seed_order.push shared_engine_path_to_engine_name(path)
            else
              warning "Seed order engine path [#{path}] is not mounted.  Skipping seeds for this engine.\n\n"
            end
          end
          seed_order
        end

        def information_message(platform_name, section)
          info "[info] Using seed order from platform [#{platform_name}] section [#{section}]"
        end

        # Convience method to engine.loaded?(name) using the path
        def engine_path_loaded?(path)
          name = shared_engine_path_to_engine_name(path)
          return true if totem_settings.engine.loaded?(name)
          warning "Engine name [#{name}] is not loaded.  Skipping engine."
          false
        end

        include Shared

      end
    end
  end
end