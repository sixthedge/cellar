require 'totem/core/oauth/exceptions'

module Totem
  module Core
    module Support
      class Oauth

          # Should always use the public methods to access these instance variables.
          # Listing the instance variables used to provide easily access if needed.
          attr_reader :totem_settings
          attr_reader :loaded_providers
          attr_reader :platform_active_providers
          attr_reader :platform_api_requests

          def initialize(env)
            @totem_settings   = env
            @loaded_providers = ::Rails.application.secrets.totem_oauth_providers || Hash.new
          end

          def oauth; self; end

          def reset
            @platform_active_providers = nil
            @platform_api_requests     = nil
            self
          end

          def reload_providers(hash); @loaded_providers = hash; reset; end

          # Can be used when the platform name or a current object is not available (e.g. rake task)
          # but a glob route (e.g. the main platform) exists.
          def default_platform_name
            glob_routes = totem_settings.registered.engine_glob_routes
            glob_route  = glob_routes.first || Hash.new
            glob_route[:platform_name]
          end

          # ### Oauth API Request Section.

          def create_user(platform_name, params={}, options={});  platform_api(platform_name).create_user(params.deep_dup, options); end
          def email_check(platform_name, params={});              platform_api(platform_name).email_check(params.deep_dup); end
          def email_exists?(platform_name, params={});            platform_api(platform_name).email_exists?(params.deep_dup); end
          def verify_password(platform_name, params={});          platform_api(platform_name).verify_password(params.deep_dup); end
          def password_valid?(platform_name, params={});          platform_api(platform_name).password_valid?(params.deep_dup); end
          def reset_password(platform_name, params={});           platform_api(platform_name).reset_password(params.deep_dup); end
          def get_password_reset_token(platform_name, params={}); platform_api(platform_name).get_password_reset_token(params.deep_dup); end
          def set_password_from_token(platform_name, params={});  platform_api(platform_name).set_password_from_token(params.deep_dup); end

          def current_create_user(object, params={}, options={});  create_user(get_platform_name(object), params, options); end
          def current_email_check(object, params={});              email_check(get_platform_name(object), params); end
          def current_email_exists?(object, params={});            email_exists?(get_platform_name(object), params); end
          def current_verify_password(object, params={});          verify_password(get_platform_name(object), params); end
          def current_password_valid?(object, params={});          password_valid?(get_platform_name(object), params); end
          def current_reset_password(object, params={});           reset_password(get_platform_name(object), params); end
          def current_get_password_reset_token(object, params={}); get_password_reset_token(get_platform_name(object), params); end
          def current_set_password_from_token(object, params={});  set_password_from_token(get_platform_name(object), params); end

          # ### Oauth API Section.

          def api_requests; @platform_api_requests ||= get_api_requests; end

          def platform_api(platform_name)
            raise PlatformNameBlank, "Platform API platform name is blank."  if platform_name.blank?
            request = api_requests[platform_name]
            raise PlatformApiBlank, "Platform API is blank for platform name #{platform_name.inspect}."  if request.blank?
            request
          end

          # ### Oauth Providers Section.

          def providers; @platform_active_providers ||= PlatformActiveProviders.new.providers(loaded_providers); end

          def platform_providers(platform_name)
            raise PlatformNameBlank, "Platform providers platform name is blank."  if platform_name.blank?
            hash = providers[platform_name]
            raise PlatformProvidersBlank, "Platform providers are blank for platform name #{platform_name.inspect}."  if hash.blank?
            hash
          end

          def current_platform_providers(object); platform_providers(get_platform_name(object)); end

          def platform_provider(platform_name, provider); platform_providers(platform_name)[provider] || {}; end

          def current_platform_provider(object, provider); platform_provider(get_platform_name(object), provider); end

          # ### Private.

          private

          def get_platform_name(object); totem_settings.engine.current_platform_name(object); end

          def get_api_requests
            api_providers = Hash.new
            providers.each do |platform_name, platform_providers|
              api_class                    = totem_settings.classes[platform_name].oauth_api
              providers_in_order           = platform_providers.values.sort_by {|p| p.order}
              api_providers[platform_name] = api_class.new(providers_in_order)
            end
            api_providers
          end

          include Shared

          # Encapsulating this in a class to prevent any naming conflicts with the base class.
          class PlatformActiveProviders

            attr_reader :platform_active_providers

            def initialize(platform_active_providers=Hash.new)
              @platform_active_providers = platform_active_providers
            end

            def providers(loaded_providers)
              loaded_providers.deep_symbolize_keys.each do |provider_name, config|
                platforms = ::Totem::Settings.registered.non_framework_platforms
                add_provider_to_platforms(provider_name, config, platforms)
              end
              debug_message
              platform_active_providers
            end

            def add_provider_to_platforms(provider_name, provider_config, platforms)
              platforms.each do |platform_name|
                add_platform_provider(provider_name, provider_config, platform_name, provider_config)
              end
            end

            def add_platform_provider(provider_name, provider_config, platform_name, platform_config)
              platform_name        = platform_name.to_s
              providers            = platform_active_providers[platform_name] || ActiveSupport::OrderedOptions.new
              config               = providers[provider_name] || ActiveSupport::OrderedOptions.new
              config.provider      = ActiveSupport::OrderedOptions[provider_config.except(:client_id, :client_secret).deep_dup]
              config.provider.name = provider_name
              config.provider.site = config.provider.site.chop  if config.provider.site.end_with?('/')
              config.platform      = ActiveSupport::OrderedOptions[platform_config.except(:site).deep_dup.merge(name: platform_name)]
              config.order         = platform_config[:order] || provider_config[:order] || providers.keys.length + 1
              providers[provider_name]                 = config
              platform_active_providers[platform_name] = providers
            end

            def debug_message
              if platform_active_providers.blank?
                debug "Oauth providers active: None."
                return
              end
              debug "Oauth providers active:"
              platforms = platform_active_providers.keys.sort
              platforms.each do |platform_name|
                providers = platform_active_providers[platform_name]
                providers.each do |provider_name, config|
                  debug "  #{platform_name.inspect}: #{provider_name.to_s.inspect} site: #{config.provider.site.inspect}"
                end
              end
            end

            include Shared

          end

      end
    end
  end
end
