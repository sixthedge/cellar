module Thinkspace
  module Common
    module Api
      module Admin
        class InvitationsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class, except: [:fetch_state]
          totem_action_serializer_options
          before_action :set_invitable, only: [:create]

          def create
            email = params_root[:email]
            email = email.strip if email.present?
            role  = params_root[:role]
            user  = Thinkspace::Common::User.find_by(email: email)

            if user.present?
              # Add to space if no SpaceUser exists.
              @space_user = Thinkspace::Common::SpaceUser.find_by(user_id: user.id, space_id: @invitation.invitable.id)
              unless @space_user.present?
                @space_user = Thinkspace::Common::SpaceUser.create(user_id: user.id, space_id: @invitation.invitable.id, role: role)
                @space_user.notify_added_to_space(current_user)
              end
              render_invitation_json
            else
              @invitation.role      = role
              @invitation.email     = email
              @invitation.sender_id = current_user.id
              @invitation.save ? render_invitation_json : controller_render_error(@invitation)
            end

          end

          def fetch_state
            @invitation = invitation_class.find_by(token: params[:id])
            controller_render_json({state: @invitation.state}) if @invitation.present?
            controller_render_json({state: nil}) unless @invitation.present?
          end

          def destroy
            controller_destroy_record(@invitation)
          end

          def refresh
            @invitation.refresh
            controller_render(@invitation)
          end

          def resend
            @invitation.resend
            controller_render(@invitation)
          end

          private

          def invitation_class; Thinkspace::Common::Invitation; end
          def space_class; Thinkspace::Common::Space; end
          def file_class; Thinkspace::Importer::File; end

          def set_invitable
            invitable_type = params_root[:invitable_type]
            invitable_id   = params_root[:invitable_id]
            klass          = invitable_type.classify.safe_constantize
            permission_denied unless klass.present?
            invitable = klass.find(invitable_id)
            ability   = platform_ability(@invitation)
            permission_denied unless ability.can?(:update, invitable)
            @invitation.invitable = invitable
          end

          def render_invitation_json
            @space_user.present? ? json = controller_as_json([@space_user]) : json = controller_as_json(@invitation)
            controller_render_json(json)
          end

          def permission_denied(message='Cannot access this resource.', options={})
            action = options[:action] ||= :unknown
            raise_access_denied_exception(message, action, nil, options)
          end

        end
      end
    end
  end
end