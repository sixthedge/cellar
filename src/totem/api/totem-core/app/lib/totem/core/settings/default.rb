# IMPORTANT: When setting values such as classes, make sure to do in dependency order.
# For example: Totem.Authentication::Api::AuthenticationController depends on
# the Totem::Authentication::Api::BaseController, so must set the base controller first.
module Totem
  module Core
    module Settings
      class Default

        attr_reader :totem_settings

        def initialize(env)
          @totem_settings = env
        end

        def defaults; self; end    # define defaults

        def platform_settings(platform_name)
          error "Framework has not been set"  if framework_name.blank?
          set_module_settings(platform_name)  # modules before classes since a class will be constantized and include modules
          set_class_settings(platform_name)
          set_authentication_settings(platform_name)
          set_authorization_settings(platform_name)
        end

        private

        def set_class_settings(platform_name)
          framework_classes = totem_settings.config.classes(framework_name) || {}
          warning "No framework [#{framework_name}] configuration classes in configuration file"  if framework_classes.blank?
          platform_classes = totem_settings.config.classes(platform_name) || {}
          result_classes   = HashWithIndifferentAccess.new( framework_classes.deep_merge(platform_classes) )     # use framework as base
          settings         = totem_settings.class[platform_name] = ConfigClass.new
          result_classes.each_pair do |key, class_name|
            settings.set_class(key, class_name)
          end
        end

        def set_module_settings(platform_name)
          framework_modules = totem_settings.config.modules(framework_name) || {}
          warning "No framework [#{framework_name}] configuration modules in configuration file"  if framework_modules.blank?
          platform_modules = totem_settings.config.modules(platform_name) || {}
          result_modules   = HashWithIndifferentAccess.new( framework_modules.deep_merge(platform_modules) )     # use framework as base
          settings         = totem_settings.module[platform_name] = ConfigModule.new
          result_modules.each_pair do |key, module_name|
            settings.set_module(key, module_name)
          end
        end

        def set_authentication_settings(platform_name)
          error "Authentication settings for [#{platform_name}] already exist"  if totem_settings.authentication.platform(platform_name).present?
          settings       = ActiveSupport::OrderedOptions.new
          framework_auth = totem_settings.config.authentication(framework_name) || {}
          warning "No framework [#{framework_name}] authentication values in configuration file"  if framework_auth.blank?
          platform_auth   = totem_settings.config.authentication(platform_name) || {}
          result_settings = HashWithIndifferentAccess.new( framework_auth.deep_merge(platform_auth) )
          settings        = add_ordered_options(platform_name, result_settings, settings, true)
          warning "Missing authentication settings for [#{platform_name}]"  if settings.blank?
          totem_settings.authentication.set_platform(platform_name, settings)
        end

        def set_authorization_settings(platform_name)
          error "Authorization settings for [#{platform_name}] already exist"  if totem_settings.authorization.platform(platform_name).present?
          settings       = ActiveSupport::OrderedOptions.new
          framework_auth = totem_settings.config.authorization(framework_name) || {}
          warning "No framework [#{framework_name}] authentication values in configuration file"  if framework_auth.blank?
          platform_auth   = totem_settings.config.authorization(platform_name) || {}
          result_settings = HashWithIndifferentAccess.new( framework_auth.deep_merge(platform_auth) )
          settings        = add_ordered_options(platform_name, result_settings, settings, true)
          warning "Missing authorization settings for [#{platform_name}]"  if settings.blank?
          totem_settings.authorization.set_platform(platform_name, settings)
        end

        def add_ordered_options(platform_name, result_settings, settings, nest_options=false, nested_classes=false, nested_modules=false)
          result_settings.each_pair do |key, value|
            if value.kind_of?(Hash) && nest_options
              if key == 'classes'
                settings[key] = ConfigClass.new
                add_ordered_options(platform_name, value, settings[key], true, true)
              elsif key == 'modules'
                settings[key] = ConfigModule.new
                add_ordered_options(platform_name, value, settings[key], true, false, true)
              else
                settings[key] = ActiveSupport::OrderedOptions.new
                add_ordered_options(platform_name, value, settings[key], true)
              end
            else
              if nested_classes
                settings.set_class(key, value)
              elsif nested_modules
                settings.set_module(key, value)
              else
                settings[key] = value
              end
            end
          end
          settings
        end

        def framework_name
          totem_settings.registered.framework_name
        end

        def get_class(name)
          error "Cannot contantize blank class name"    if name.blank?
          klass = name.safe_constantize
          error "Cannot contantize class name #{name}"  if klass.blank?
          klass
        end

        include ::Totem::Core::Support::Shared

      end
    end
  end
end