module TestThinkspace
  module Authorization
    module ThinkspaceCommon

      def thinkspace_common_ability
        thinkspace_common_ability_all
      end

      def thinkspace_common_user_class;  Thinkspace::Common::User; end
      def thinkspace_common_space_class; Thinkspace::Common::Space; end
      def thinkspace_common_password_reset_class; Thinkspace::Common::PasswordReset; end
      def thinkspace_common_space_user_class; Thinkspace::Common::SpaceUser; end
      def thinkspace_common_space_type_class; Thinkspace::Common::SpaceType; end
      def thinkspace_common_invitation_class; Thinkspace::Common::Invitation; end

      # ###
      # ### Can
      # ###

      def thinkspace_common_ability_all
        can [:read], Thinkspace::Common::SpaceType
        can [:read], Thinkspace::Common::Configuration
        can [:read], Thinkspace::Common::Component
        can [:read], Thinkspace::Team::TeamTeamable if (!!Thinkspace::Team rescue false)

        can [:sign_in, :sign_out, :stay_alive, :validate, :create], thinkspace_common_user_class

        can [:read], thinkspace_common_user_class, where_user(:id)

        can [:create, :read, :update], thinkspace_common_password_reset_class
        can [:read],                thinkspace_common_space_class, thinkspace_common_space_read
        can [:create],              thinkspace_common_space_class

        # Allow a user to read the space owners (e.g. a space summary view).
        can [:read_space_owners], thinkspace_common_user_class,  thinkspace_common_space_owner_users
        can [:read_space_owners], thinkspace_common_space_user_class, thinkspace_common_space_user_owner_roles

        can [:view], Thinkspace::Common::SpaceUser, thinkspace_common_space_user_owner_roles

        can [:view], Thinkspace::Common::User

        # ###
        # ### Admin additions
        # ###
        can [:update, :clone, :roster, :invitations, :teams, :team_sets, :invite, :import], thinkspace_common_space_class, thinkspace_common_space_update
        can [:read, :select, :refresh], thinkspace_common_user_class, { thinkspace_common_spaces: { id: user_administrative_space_ids } }
        can [:read, :update, :destroy, :resend], thinkspace_common_space_user_class, { space_id: user_administrative_space_ids }
        can [:create], thinkspace_common_invitation_class
        can [:read, :update, :destroy, :refresh, :resend, :fetch_status], thinkspace_common_invitation_class, invitable_administrative_space

      end

      # ###
      # ### Can Helpers
      # ###

      def thinkspace_common_space_read
        {thinkspace_common_space_users: where_user}
      end

      def thinkspace_common_space_update
        {thinkspace_common_space_users: where_user.merge(thinkspace_common_space_user_update_roles)}
      end

      def thinkspace_common_space_update_users
        {thinkspace_common_space_users: thinkspace_common_space_user_update_roles}
      end

      def thinkspace_common_space_owner_users
        {thinkspace_common_space_users: thinkspace_common_space_user_owner_roles}
      end

      def thinkspace_common_space_read_users
        {thinkspace_common_space_users: thinkspace_common_space_user_read_roles}
      end

      def thinkspace_common_space_user_read_roles
        {role: 'read'}
      end

      def thinkspace_common_space_user_owner_roles
        {role: 'owner'}
      end

      def thinkspace_common_space_user_update_roles
        {role: ['owner', 'update']}
      end

      def where_user(col=:user_id)
        {col => user.id}
      end

      def user_administrative_space_ids
        user.thinkspace_common_space_users.where(thinkspace_common_space_user_update_roles).pluck(:space_id)
      end

      def invitable_administrative_space
        { invitable_type: thinkspace_common_space_class.name, invitable_id: user_administrative_space_ids }
      end

      # ###
      # ### Can Ownerable
      # ###

      # Create 'can' rules that will be OR'd together where 'ownerable_type = class.name' and 'ownerable_id = id | [ids]'.
      # Downside:
      #  - When the there are multiple ids, they must be extracted each time the ability file is created.
      #  - The generated SQL will always include the OR'd rules with all ids (e.g. for each class.name).

      def can_ownerable(actions, klass)
        [actions].flatten.each do |action|
          can [action], klass, ownerable_user
          can [action], klass, ownerable_collaboration_team
        end
      end

      def can_ownerable_association(actions, klass, association)
        [actions].flatten.each do |action|
          can [action], klass, {association => ownerable_user}
          can [action], klass, {association => ownerable_collaboration_team}
        end
      end

      def can_view_ownerable(actions, klass)
        [actions].flatten.each do |action|
          can [action], klass, ownerable_peer_review_team
        end
      end

      def ownerable_user
        {ownerable_type: thinkspace_common_user_class.name, ownerable_id: user.id}
      end

      def ownerable_collaboration_team
        {ownerable_type: thinkspace_team_team_class.name, ownerable_id: thinkspace_team_collaboration_ids}
      end

      def ownerable_peer_review_team
        {ownerable_type: thinkspace_common_user_class.name, ownerable_id: thinkspace_team_peer_review_user_ids}
      end

    end
  end
end
