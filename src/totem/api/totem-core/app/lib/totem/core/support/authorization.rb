module Totem
  module Core
    module Support
      class Authorization

        attr_reader :totem_settings

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :platform_authorization_settings

        def initialize(env)
          @totem_settings                  = env
          @platform_authorization_settings = ActiveSupport::OrderedOptions.new
        end

        # define authorization.
        def authorization; self; end

        def platform(platform_name)
          error "Platform [#{platform_name.inspect}] is blank" if platform_name.blank?
          platforms[platform_name]
        end

        def platforms
          platform_authorization_settings
        end

        def set_platform(platform_name, settings)
          error "Platform [#{platform_name}] is blank in set platform" if platform_name.blank?
          @platform_authorization_settings[platform_name] = settings
        end

        def authorize_config(platform_name, auth_by)
          platform(platform_name) && platform(platform_name)[auth_by]
        end

        # ability class for authorize_by name
        def current_authorize_by(object)
          authorize_by(get_current_platform_name(object))
        end

        def authorize_by(platform_name)
          platform(platform_name) && platform(platform_name).authorize_by
        end

        # ability class for authorize_by name
        def current_ability_class(object)
          ability_class(get_current_platform_name(object))
        end

        def ability_class(platform_name)
          auth_classes = get_authorization_values(platform_name, :classes)
          return nil if auth_classes.blank?
          auth_classes.ability
        end

        # serializer include modules
        def current_serializer_include_modules(object)
          serializer_include_modules(get_current_platform_name(object))
        end

        def serializer_include_modules(platform_name)
          auth_modules = get_authorization_serializer_values(platform_name, :modules)
          return nil if auth_modules.blank?
          auth_modules.get_all
        end

        # serializer defaults
        def current_serializer_defaults(object)
          serializer_defaults(get_current_platform_name(object))
        end

        def serializer_defaults(platform_name)
          get_authorization_serializer_values(platform_name, :defaults)
        end

        private

        def get_current_platform_name(object)
          totem_settings.engine.current_platform_name(object)
        end

        def get_authorization_values(platform_name, key=nil)
          auth = platform(platform_name)
          return nil if auth.blank?
          auth_by = auth.authorize_by
          return nil if auth_by.blank?
          auth_by_values = auth[auth_by]
          return nil if auth_by_values.blank?
          return auth_by_values if key.blank?
          auth_by_values[key]
        end

        def get_authorization_serializer_values(platform_name, key)
          serializer_values = get_authorization_values(platform_name, :serializers)
          return nil if serializer_values.blank?
          serializer_values[key]
        end

        include Shared

      end
    end
  end
end