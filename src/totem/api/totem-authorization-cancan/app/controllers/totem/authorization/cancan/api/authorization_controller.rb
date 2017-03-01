module Totem
  module Authorization
    module Cancan
      module Api
        class AuthorizationController < Totem::Settings.class.totem.authentication_api_controller

          protected

          include ::Totem::Authorization::Cancan::Controllers::CurrentAbility

          rescue_from ::CanCan::AccessDenied do |e|
            render json: {:errors => cancan_message(e)}, status: 423
          end

          def raise_access_denied_exception(message=nil, action=nil, subject=nil, options={})
            message = cancan_access_denied_message(message, action, subject, options)
            raise ::CanCan::AccessDenied.new(message, action, subject)
          end

          private

          def default_cancan_access_denied_message
            'You are not authorized to access this resource.'
          end

          # Return an access denied message hash.
          # The message hash contains a 'message' and an optional options[:user_message] e.g. a user friendly message.
          # The 'message' is always the 'default_cancan_access_denied_message'.
          # If not production, an options[:debug] hash is created by merging the options hash (except for the user_message).
          # Note: The ember totem-messages 423 api failure default message (e.g. when this hash has a blank user_message) is the
          #       ember locales i18n message not the message in this hash.
          def cancan_access_denied_message(message, action, subject, options)
            hash = Hash.new
            hash[:message]      = default_cancan_access_denied_message
            hash[:user_message] = options[:user_message]  if options.has_key?(:user_message)
            if cancan_include_debug_info?
              hash[:debug] = Hash.new
              hash[:debug].merge! options.except(:user_message)
              hash[:debug][:message] = message  if message.present?
            end
            hash
          end

          # Always return a hash for 423 error messages with a 'message' key and possible other keys e.g. 'user_message' key.
          # Already is a hash when formatted by the 'raise_access_denied_exception' method.
          def cancan_message(e)
            hash = e.message
            hash = {message: e.message}  unless hash.kind_of?(Hash)
            if cancan_include_debug_info?
              debug = hash[:debug] || Hash.new
              debug = {debug: debug}  unless debug.kind_of?(Hash)
              if current_user.present?
                debug[:current_username] = current_user.username
                debug[:current_user_id]  = current_user.id
              end
              if current_ability.respond_to?(:user_role)
                role         = current_ability.user_role
                debug[:role] = role.blank? ? 'not set' : role
              end
              debug[:action]  = e.action.inspect
              debug[:action] += " (action must be a symbol)"  unless e.action.kind_of?(Symbol)
              if (subject = e.subject).present?
                debug[:subject]    = subject.kind_of?(String) ? subject : subject.kind_of?(Class) ? subject.name : subject.class.name
                debug[:subject_id] = subject.id  if subject.respond_to?(:id)
              end
              hash[:debug] = debug
            end
            hash
          end

          def cancan_include_debug_info?
            !Rails.env.production?
          end

        end
      end
    end
  end
end
