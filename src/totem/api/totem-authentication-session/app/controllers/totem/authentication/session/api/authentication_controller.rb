module Totem
  module Authentication
    module Session
      module Api

        class AuthenticationController < ::Totem::Settings.class.totem.application_controller
          respond_to :json
          before_action :set_to_json
          protect_from_forgery unless: -> { request.format.json? }
          before_action :totem_authenticate_user_from_token!, except: [:sign_in, :sign_out]
          before_action :set_paper_trail_whodunnit if defined?(::PaperTrail)

          private

          # For non-get requests (e.g. post, put, etc.), if the Rails server is configured as an API server
          # (config/application.rb includes 'config.api_only = true') when calling 'protect_from_forgery' 
          # Rails raises the error (sets the flash to nil):
          #   'NoMethodError (undefined method `flash=' for #<ActionDispatch::Request:)'.
          # Removing 'protect_from_forgery' will raise the error:
          #   'ArgumentError (Before process_action callback :verify_authenticity_token has not been defined)'.
          # The root cause seems to be when a non-get request is processed it is processed as 'HTML' rather than 'JSON'.
          # Tried differect solutions:
          #   * Changing the ajax header values (e.g. Accepts and Content-Type) but did not change to 'JSON'.
          #   * Adding data.format='json' in the ajax request did work, but may not work in all cases.
          # Implemented forcing the 'request.format' to 'json' in a before action and adding an 'unless'
          # clause to the 'protect_from_forgery'.
          def set_to_json; request.format = :json; end

          def current_user; @current_user; end

          def set_current_user(user); @current_user = user; end

          include ::Totem::Settings.module.totem.controller_model_class
          include ::Totem::Settings.module.totem.controller_params
          include ::Totem::Settings.module.totem.controller_api_render
          include ::Totem::Settings.module.totem.controller_json_api

          # ###
          # ### Rescue and Render from Some Authentication Errors.
          # ###

          rescue_from SessionCredentialsError do |e|
            set_current_user(nil)
            message = Rails.env.production? ? 'Invalid credentials.' : e.message
            render text: message, status: 501
          end

          rescue_from SessionTimeoutError do |e|
            set_current_user(nil)
            path    = request.original_fullpath
            message = e.message
            render json: { :path => path, message: message }, status: 511
          end

          rescue_from SessionExpiredError do |e|
            set_current_user(nil)
            path    = request.original_fullpath
            message = e.message
            render json: { :path => path, message: message }, status: 511
          end

          # ###
          # ### totem_authenticate_user_from_token!
          # ###

          def totem_authenticate_user_from_token!
            authenticate_with_http_token do |auth_token, options|
              authenticate_user_from_auth_token(auth_token, options[:email])
            end
          end

          # ###
          # ### totem_sign_in_user!
          # ###

          def totem_sign_in_user!
            identification = params[:identification]
            password       = params[:password]
            authenticate_session_sign_in(identification, password)
          end

          # ###
          # ### totem_sign_out_user!
          # ###

          def totem_sign_out_user!
            authenticate_with_http_token do |auth_token, options|
              email = options[:email]
              case
              when !Rails.env.production? && session_api_session_model_class.count == 0
              when auth_token.present? && email.present?
                authenticate_user_from_auth_token(auth_token, email)
                delete_api_session(current_user)
              when auth_token.blank? && email.blank?
              when email.present?
                raise SessionCredentialsError, "Cannot sign out with only email [email: #{email.inspect}]."
              else
                raise SessionCredentialsError, "Cannot sign out with only an auth token."
              end
            end
          end

          # ###
          # ### Authenticate a User from the Token (verify session is not timeout/expired).
          # ###

          def authenticate_user_from_auth_token(auth_token, email)
            raise SessionMissingIdentification, "Email for authorize token is blank."  if email.blank?
            raise SessionMissingAuthToken, "Missing user auth token [email: #{email.inspect}]."  if auth_token.blank?

            user = session_user_model_class.find_by(email: email)
            raise SessionInvalidIdentification, "User [email: user.email.inspect] not found."  if user.blank?

            api_session = read_api_session(user)
            unless secure_compare(auth_token, api_session.authentication_token)
              raise SessionInvalidUser, "User [user_id: #{user.id}] has invalid api session token."
            end

            unless session_sign_out?
              check_api_session_timeout(api_session)
              check_api_session_expired(api_session)
              api_session.touch
            end

            set_current_user(user)
          end

          def check_api_session_timeout(api_session)
            timeout_interval = ::Totem::Settings.authentication.current_session_timeout(self) || 0
            timeout_at       = api_session.updated_at + timeout_interval
            raise SessionTimeoutError, "Session timeout."  unless timeout_at > session_time_now
          end

          def check_api_session_expired(api_session)
            expire_interval = ::Totem::Settings.authentication.current_session_expire_after(self) || 0
            expire_at       = api_session.created_at + expire_interval
            raise SessionExpiredError, "Session expired."  unless expire_at > session_time_now
          end

          def session_sign_out?
            self.action_name == 'sign_out'
          end

          # ###
          # ### Authenticate Sign In Credentials.
          # ###

          def authenticate_session_sign_in(identification, password)
            raise SessionCredentialsInvalidIdentification, "Identification value is blank"  if identification.blank?
            user = session_user_model_class.find_by(email: identification)

            if user.present?
              # TODO: This may need to sync the credentials.
              # User model doesn't have password (it is in oauth), so send a S2S request to OAuth to verify the password.
              # raise CredentialsInvalidPassword, "Invalid password" unless user.authenticate(password) # if user model had a password
              raise SessionCredentialsInvalidPassword, "Invalid password" unless is_password_valid?(identification, password)
              set_current_user(user)
              find_or_create_api_session(user)
            else
              oauth_user = get_oauth_user(identification, password)
              if oauth_user['valid']
                create_user_from_oauth_user(identification, oauth_user)
              else
                raise SessionCredentialsInvalidIdentification, 'Invalid identification value.' # no OAuth user present
              end
            end
          end

          def create_user_from_oauth_user(identification, oauth_data)
            user = session_user_model_class.new
            user.sync_user_from_oauth_data(oauth_data)
            user.callback_created_from_oauth if user.respond_to?(:callback_created_from_oauth)
            set_current_user(user)
            create_api_session(user)
          end

          def get_oauth_user(identification, password=nil)
            raise SessionCredentialsInvalidIdentification, "Identification value is blank, cannot call [get_oauth_user]"  if identification.blank?
            raise SessionCredentialsInvalidIdentification, "Password value is blank, cannot call [get_oauth_user]"  if password.blank?
            ::Totem::Settings.oauth.current_verify_password(self, email: identification, password: password)
          end

          def is_password_valid?(identification, password)
            raise SessionCredentialsInvalidIdentification, "Identification value is blank"  if identification.blank?
            raise SessionCredentialsInvalidPassword, "Password is blank" if password.blank?
            ::Totem::Settings.oauth.current_password_valid?(self, email: identification, password: password)
          end

          # ###
          # ### Api Session CRUD.
          # ###

          # If get duplicate auth tokens, change to a where() and match on email/identification (should never happens).
          def read_api_session(user)
            user_id     = get_session_user_id(user)
            api_session = session_api_session_model_class.find_by(user_id: user_id)
            raise SessionInvalidUserAuthToken, "Api Session [user_id: #{user_id}] not found."  if api_session.blank?
            api_session
          end

          def create_api_session(user)
            delete_api_session(user)
            api_session                      = session_api_session_model_class.new
            api_session.user_id              = user.id
            api_session.authentication_token = generate_authentication_token
            raise SessionSaveError, "Could not save api session record for [user id: #{user.id}]."  unless api_session.save
            user.callback_new_api_session if user.respond_to?(:callback_new_api_session)
            api_session
          end

          def find_or_create_api_session(user)
            user_id     = get_session_user_id(user)
            api_session = session_api_session_model_class.find_by(user_id: user_id)
            if api_session.present?
              begin
                check_api_session_timeout(api_session)
                check_api_session_expired(api_session)
                api_session
              rescue
                create_api_session(user)
              end
            else
              create_api_session(user)
            end
          end

          def update_api_session_alive(user)
            api_session = read_api_session(user)
            api_session.touch
          end

          def delete_api_session(user)
            user_id = get_session_user_id(user)
            session_api_session_model_class.where(user_id: user_id).delete_all
          end

          def get_session_user_id(user)
            raise SessionUserError, "Session user is blank."  if user.blank?
            raise SessionUserError, "Not a user instance."    unless user.instance_of?(session_user_model_class)
            user_id = user.id
            raise SessionUserError, "Session user_id is blank."  if user_id.blank?
            user_id
          end

          # ###
          # ### Helpers.
          # ###

          def session_time_now; @_session_time_now ||= Time.now.utc; end

          def session_user_model_class
            @_session_user_class ||= ::Totem::Settings.authentication.current_model_class(self, :user_model)
            raise SessionUserClass, "Unknown platform user model class for #{self.class.name}."  if @_session_user_class.blank?
            @_session_user_class
          end

          def session_api_session_model_class
            @_api_session_class ||= ::Totem::Settings.authentication.current_model_class(self, :api_session_model)
            raise SessionApiSessionClass, "Unknown platform api session model class for #{self.class.name}."  if @_api_session_class.blank?
            @_api_session_class
          end

          # From Devise.

          # devise.rb method self.friendly_token
          def generate_authentication_token
            SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
          end

          # constant-time comparison algorithm to prevent timing attacks
          def secure_compare(a, b)
            return false if a.blank? || b.blank? || a.bytesize != b.bytesize
            l = a.unpack "C#{a.bytesize}"
            res = 0
            b.each_byte { |byte| res |= byte ^ l.shift }
            res == 0
          end

        end

      end
    end
  end
end
