module Thinkspace
  module Common
    module Api
      class UsersController < Totem::Settings.class.thinkspace.authorization_api_controller
        skip_before_action :verify_authenticity_token, only: [:sign_in, :sign_out, :create]
        before_action :validate_token_and_set_user, only: [:create]
        load_and_authorize_resource class: totem_controller_model_class, except: [:sign_in, :sign_out, :create]
        totem_action_serializer_options

        def show
          raise "User [id: #{@user.id}] is not current user [id: #{current_user.id}]"  unless @user.id == current_user.id
          serializer_options.remove_all
          controller_render(current_user)
        end

        def create
          Thinkspace::Common::User.transaction do
            response = nil
            begin
              response = ::Totem::Settings.oauth.current_create_user(self, params)
            rescue => e
              permission_denied(e.message)
            end
            permission_denied(parse_s2s_errors(response['errors'])) unless response['valid'] # Invalid creation from S2S
            set_user_values(response)
            update_terms_accepted_at
            if @user.save
              @user.activate!
              controller_render(@user)
            else
              permission_denied('User credentials could not be validated. Please contact support.')
            end
          end
        end

        def avatar
          attachment   = params[:files].first
          @user.avatar = attachment
          controller_save_record(@user)
        end

        def update
          set_user_values
          process_updates
          controller_save_record(@user)
        end

        def update_tos
          update_terms_accepted_at
          controller_save_record(@user)
        end

        include ::Totem::Settings.module.thinkspace.session_user_actions
        include ::Totem::Settings.module.thinkspace.lti_user_actions

        private

        def user_class; Thinkspace::Common::User; end
        def space_user_class; Thinkspace::Common::SpaceUser; end

        def parse_s2s_errors(errors)
          # return first error
          return 'There was a problem creating your account.' if (not errors.present? or errors.empty?)
          errors.each do |key, value|
            return (key + ' ' + value.first).capitalize
          end
        end

        def get_email_from_params; params_root[:email].strip.downcase; end

        def validate_token_and_set_user
          email = get_email_from_params
          @user = user_class.find_by(email: email)
          token = params_root[:token]
          case
          when (token.present? && @user.present?)
            # Valid invitation case.
            permission_denied('The invitation has already been accepted.') if @user.active?
            permission_denied('User was invited, but no invitation token was provided. Check your email for an invitation link and use it to sign up.') unless token.present?
            permission_denied('The invitation token is invalid. Please contact your instructor.') unless token == @user.activation_token
            permission_denied('The invitation has expired. Please contact your instructor.') if @user.activation_expired?
            params['data']['attributes']['email'] = @user.email # Ensure that the params email is the invitation email.
          when (token.present? && !@user.present?)
            # Invalid invitation case.
            permission_denied('No user was found for the given token.')
          when (!token.present? && !@user.present?)
            # New user creation without invitation.
            @user = user_class.new(email: email)
          else
            permission_denied('An error has occured during account creation.  Please try again.  If the error persists, contact support.')
          end
        end


        def render_user_creation_error(errors={})
          render json: errors.as_json, status: 403
        end

        def permission_denied(message='Cannot access this resource.', options={})
          options[:user_message] = message
          raise_access_denied_exception(message, :create, nil, options)
        end

        def update_terms_accepted_at
          # @user.terms_accepted_at = Time.now
        end

        def set_user_values(s2s_params={})
          if s2s_params.empty?
            @user.oauth_user_id = response['id']
            @user.first_name    = response['first_name']
            @user.last_name     = response['last_name']
            @user.email         = response['email']
          else
            @user.first_name                       = params_root[:first_name]
            @user.last_name                        = params_root[:last_name]
          end
          @user.email_optin                      = params_root[:email_optin]
          @user.profile                          = params_root[:profile]
          @user.thinkspace_common_discipline_ids = params_root['thinkspace/common/disciplines']
        end

        def process_updates
          updates = params_root[:updates]
          if updates.present?
            if updates.has_key?(:disciplines)
              discipline_change = updates[:disciplines]
              ids = discipline_change
              @user.thinkspace_common_discipline_ids = ids
            end
          end
        end

      end
    end
  end
end
