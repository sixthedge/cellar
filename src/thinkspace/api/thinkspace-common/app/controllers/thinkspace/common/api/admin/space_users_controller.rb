module Thinkspace
  module Common
    module Api
      module Admin
        class SpaceUsersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :validate_space_user_roles, only: [:update]

          def update
            @space_user.role = params_root[:role]
            controller_save_record(@space_user)
          end

          def activate
            @space_user.activate!
            controller_render(@space_user)
          end

          def inactivate
            @space_user.inactivate!
            controller_render(@space_user)
          end

          def resend
            @space_user.notify_invited_to_space(current_user) unless @space_user.thinkspace_common_user.active?
            controller_render_json({})
          end

          private

          def validate_space_user_roles
            # If they are an owner, do not allow any role changes.
            space_id           = @space_user.space_id
            current_user_id    = current_user.id
            current_space_user = Thinkspace::Common::SpaceUser.find_by(space_id: space_id, user_id: current_user_id)
            @role              = params_root[:role]

            # Written this way for case statement as Mattias' note in: http://stackoverflow.com/questions/5111106/ruby-conditional-matrix-case-with-multiple-conditions
            user_is_space_user     = @space_user.user_id == current_user.id
            cannot_change_to_owner = current_space_user.role == 'update' && @role == 'owner'
            cannot_change_owners   = @space_user.role == 'owner' && !(current_space_user.role == 'owner')

            case
              when user_is_space_user # Disallow changing of own role.
                return access_denied_role_change('You cannot change your own role.')
              when !current_space_user.present? # Ensure space user is present.
                return access_denied_role_change('You cannot change a role on a non-existing user.')
              when cannot_change_to_owner # Do not allow updates to change someone to owner.
                return access_denied_role_change('You cannot change someone to an instructor as a teaching assistant.')
              when cannot_change_owners # Disallow changing of owners.
                return access_denied_role_change('You cannot modify instructors when you are not also an instructor.')
            end

          end

          def access_denied_role_change(user_message="You cannot change the user's role.", action='update')
            raise_access_denied_exception("Invalid role change to [#{@role}] for [#{@space_user.role}].", action, @space_user,  user_message: user_message)
          end

        end
      end
    end
  end
end
