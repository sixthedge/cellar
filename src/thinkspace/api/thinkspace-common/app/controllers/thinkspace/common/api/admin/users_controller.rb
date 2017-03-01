module Thinkspace
  module Common
    module Api
      module Admin
        class UsersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options except: :is_superuser

          def select
            @users = @users.where(id: params[:ids])
            controller_render(@users)
          end

          def refresh
            @user.refresh_activation
            controller_render(@user)
          end

          def switch
            space = get_switch_space
            authorize_switch_user(space)
            user         = get_switch_to_user(space)
            api_session  = create_api_session(user)
            hash         = controller_as_json(user)
            hash[:token] = api_session.authentication_token
            controller_render_json(hash)
          end

          def is_superuser
            access_denied "Unauthorized request." unless current_user.superuser?
            controller_render_no_content
          end

          private

          def get_switch_space
            space_id = params[:space_id]
            access_denied "Space id is blank."  if space_id.blank?
            space = space_class.find_by(id: space_id)
            access_denied "Space id #{space_id} not found."  if space.blank?
            space
          end

          def authorize_switch_user(space)
            updater      = get_switch_updater
            roles_hash   = {role: ['owner', 'update']}
            updater_hash = roles_hash.merge(space_id: space.id, user_id: updater.id)
            can_update   = space_user_class.scope_active.where(updater_hash).exists?
            access_denied "User #{updater.id} cannot update space id #{space_id}."  unless can_update
          end

          def get_switch_to_user(space)
            user = @user.parent_id.present? ? get_switch_reader_parent : get_switch_reader(space)
            access_denied "Switch user is blank."  if user.blank?
            user
          end

          def get_switch_updater;            @user.parent_id.blank? ? @user : get_switch_reader_parent; end
          def get_switch_reader_parent;      user_class.find_by(id: @user.parent_id); end
          def get_switch_reader_for_updater; user_class.find_by(parent_id: @user.id); end

          def get_switch_reader(space)
            user = get_switch_reader_for_updater
            user = create_switch_reader_for_updater if user.blank?
            ensure_is_space_reader(space, user)
            user
          end

          def create_switch_reader_for_updater
            updater     = @user
            first_name  = 'reader-' + (updater.first_name || '')
            last_name   = updater.last_name
            email       = 'reader-' + (updater.email || '')
            if user_class.find_by(email: email).present?
              email = SecureRandom.uuid + (updater.email || '')
            end
            reader_hash = {
              first_name: first_name,
              last_name:  last_name,
              email:      email,
              parent_id:  updater.id,
              state:      updater.state,
            }
            reader = user_class.create(reader_hash)
            access_denied "Could not create switch reader #{reader_hash.inspect} for updater id #{updater.id}. [errors: #{reader.errors.messages}]"  if reader.blank?
            reader
          end

          def ensure_is_space_reader(space, user)
            roles_hash  = {role: :read}
            reader_hash = roles_hash.merge(space_id: space.id, user_id: user.id)
            record      = space_user_class.find_by(reader_hash)
            if record.present?
              record.activate! unless record.active?
            else
              record = space_user_class.create(reader_hash.merge(state: :active))
              access_denied "Could not reader as a space user #{reader_hash.inspect}. [errors: #{space_user.errors.messages}]"  if space_user.blank?
            end
          end

          def user_class;       Thinkspace::Common::User; end
          def space_class;      Thinkspace::Common::Space; end
          def space_user_class; Thinkspace::Common::SpaceUser; end

          def access_denied(message, user_message='')
            raise_access_denied_exception(message, self.action_name.to_sym, @user || controller_model_class_name, user_message: user_message)
          end

        end
      end
    end
  end
end
