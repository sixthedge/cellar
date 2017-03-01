module Test; module Ability; module Controllers; module Thinkspace; module Common; module Api

  class UsersController
    # def setup_create(route); route.assert_unauthorized(/no invitation token/i); end
    def setup_create(route); route.assert_unauthorized(/already been accepted/i); end
    def setup_sign_out(route);    route.assert_authorized; end
    def setup_show(route);        route.assert_authorized; end
    def setup_stay_alive(route);  route.assert_authorized; end
    def setup_validate(route);    route.assert_authorized; end
  end
  class SpacesController
    def setup_index(route); route.assert_authorized; end
  end
  class PasswordResetsController
    def setup(route); route.assert_authorized; end
  end
  class DiscourseController
    def setup(route); route.assert_unauthorized(/are relative/i); end
  end

  module Admin
    class UsersController
      def setup_select_can_update_unauthorized(route); route.assert_authorized; end
      def setup_switch_can_update_authorized(route); route.assert_unauthorized(/space id is blank/i); end
      def setup_refresh_can_update_unauthorized(route); route.assert_authorized; end
    end
    class SpacesController
      def setup_create(route); route.assert_authorized; end
      def setup_import_can_update_authorized(route); route.assert_unauthorized(/problem processing the file/i); end
    end
    class SpaceUsersController
      def setup_update_can_update_authorized(route); route.assert_unauthorized(/invalid role change/i); end
    end
    class InvitationsController
      def setup_fetch_state_unauthorized_reader(route); route.assert_authorized; end
      def setup_fetch_state_can_update_unauthorized(route); route.assert_authorized; end
      def before_save(route)
        invitation           = route.model
        invitation.invitable = route.dictionary_space
        user                 = route.dictionary_user
        invitation.sender_id = user.id  if user.present?
      end
      def after_save_import(route)
        user = route.dictionary_user
        return if user.blank?
        route.set_params(:invitable_id, user.id)
        route.set_params(:invitable_type, user.class.name)
      end
    end

  end

end; end; end; end; end; end
