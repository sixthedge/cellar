# Authentication wrapper around other Totem::Settings.
module Totem
  module Core
    module Support
      class Authentication

        attr_reader :totem_settings

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :platform_authentication_settings

        def initialize(env)
          @totem_settings                   = env
          @platform_authentication_settings = ActiveSupport::OrderedOptions.new
        end

        # define authentication.
        def authentication; self; end

        def platforms; platform_authentication_settings; end

        def platform(platform_name)
          error "Platform [#{platform_name.inspect}] is blank" if platform_name.blank?
          platforms[platform_name]
        end

        def set_platform(platform_name, settings)
          error "Platform [#{platform_name}] is blank in set platform" if platform_name.blank?
          @platform_authentication_settings[platform_name] = settings
        end

        def model_class(platform_name, class_name=:user_model)
          platform(platform_name) && platform(platform_name).classes.get_class(class_name)
        end

        def current_model_class(object, class_name=:user_model); model_class(get_platform_name(object), class_name); end

        # ### Routes Section

        def route(platform_name, key); get_platform_name_value(platform_name, :routes, key); end

        def current_route(object, key); route(get_platform_name(object), key); end

        def current_home_route(object); current_route(object, :home); end

        # ### Session Section

        def session(platform_name); get_platform_name_value(platform_name, :session); end

        def current_session(object); session(get_platform_name(object)); end

        def session_timeout(platform_name); get_platform_name_value(platform_name, :session, :timeout_time); end

        def current_session_timeout(object); session_timeout(get_platform_name(object)); end

        def session_expire_after(platform_name); get_platform_name_value(platform_name, :session, :expire_after_time); end

        def current_session_expire_after(object); session_expire_after(get_platform_name(object)); end

        private

        def get_platform_name(object); totem_settings.engine.current_platform_name(object); end

        def get_platform_name_value(*args)
          platform_name = args.shift
          value         = platform(platform_name)
          args.each do |arg|
            value = value[arg]
            break if value.blank?
          end
          value
        end

        include Shared

      end
    end
  end
end