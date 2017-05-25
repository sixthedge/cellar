module Thinkspace
  module Common
    class Space < ActiveRecord::Base
      totem_associations

      def self.totem_cache_query_key_index(scope, ownerable, options={})
        updated_ats = scope.joins(:thinkspace_casespace_assignments).merge(Thinkspace::Casespace::Assignment.open_updated_ats(ownerable))
        dates_ats   = scope.joins(:thinkspace_casespace_assignments).merge(Thinkspace::Casespace::Assignment.open_times(ownerable))
        [:assignments] + updated_ats.map(&:v_updated_at) + dates_ats.map(&:v_release_at)
      end

      def serializer_metadata(ownerable, so)
        ownerable        ||= so.current_user
        assignments        = self.thinkspace_casespace_assignments.accessible_by(so.current_ability, :read)
        hash               = Hash.new
        hash[:count]       = assignments.count
        hash[:open]        = assignments.scope_open(ownerable).count
        hash[:next_due_at] = assignments.next_due_at(ownerable)
        hash[:can_clone]   = !assignments.scope_peer_assessment.exists?
        hash
      end

      def get_space; self; end

      def is_space_user?(user)
        return false if user.blank?
        user_id = user.respond_to?(:id) ? user.id : user
        self.thinkspace_common_space_users.where(user_id: user_id).exists?
      end

      def user_sandbox?; !sandbox? && self.sandbox_space_id.present?; end

      def sandbox?; self.sandbox_space_id == self.id; end

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      # ###
      # ### Invite.
      # ###

      def mass_invite(files, sender)
        records = []
        begin
          user_class.transaction do
            files.each do |f|
              file              = f[:file]
              data              = f[:data]
              generated_records = file.process(data)
              records           = records | generated_records
            end
            records.each do |user|
              process_imported_user(user, sender)
            end
            notify_roster_import_complete(sender, nil)
          end
        rescue => e
          notify_roster_import_complete(sender, e)
        end
        return records
      end

      def process_imported_user(user, sender, role='read')
        persisted_user = user_class.find_by(email: user.email)
        if persisted_user.present?
          persisted_user.refresh_activation unless persisted_user.is_activated?
          space_user = space_user_class.find_by(space_id: self.id, user_id: persisted_user.id)
          unless space_user.present?
            space_user = space_user_class.create(space_id: self.id, user_id: persisted_user.id, role: role)
            space_user.activate!
            if persisted_user.active? then space_user.notify_added_to_space(sender) else space_user.notify_invited_to_space(sender) end
          end
          persisted_user
        else
          if user.save
            space_user = space_user_class.create(space_id: self.id, user_id: user.id, role: role)
            space_user.activate!
            space_user.notify_invited_to_space(sender)
          end
          user
        end
      end

      def notify_roster_import_complete(sender, status)
        notification_mailer_class.roster_imported(sender, status, self).deliver_now
      end

      # ###
      # ### Clone Space
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone_with_notification(user, options={})
        begin
          cloned_space = cyclone(options)
          notification_mailer_class.space_clone_completed(user, self, cloned_space).deliver_now
        rescue
          notification_mailer_class.space_clone_failed(user, self).deliver_now
        end
      end
      handle_asynchronously :cyclone_with_notification

      def cyclone(options={})
        self.transaction do
          options[:dictionary] ||= get_clone_dictionary(options)
          clone_associations = get_clone_associations(options)
          cloned_space       = clone_self(options, clone_associations)
          cloned_space.title = get_clone_title(self.title, options)
          clone_save_record(cloned_space)
          options.merge!(keep_title: true, is_full_clone: true)
          # The 'associations.yml' has the space's assignments as readonly.
          # Doing a 'deep_clone' of an assignment will raise:
          #   "ActiveRecord::ReadOnlyRecord: Thinkspace::Casespace::Assignment is marked as readonly"
          # (even though the assignment is not updated).
          assignments = thinkspace_casespace_assignments.readonly(false)
          assignments.each do |assignment|
            assignment.cyclone(options)
          end
          cloned_space.clone_instructors(self)
          cloned_space
        end
      end

      def clone_instructors(original_space)
        raise_clone_exception("Cannot clone instructors without an original space.") if original_space.blank?
        instructor_roles = ['update', 'owner']
        space_users      = original_space.thinkspace_common_space_users.where(role: instructor_roles)
        space_users.each do |su|
          self.thinkspace_common_space_users << Thinkspace::Common::SpaceUser.create(user_id: su.user_id, role: su.role, state: 'active')
        end
      end

      def add_user_as_owner(user)
        add_user_as_role(user, 'owner')
      end

      # # Teams
      def ensure_default_team_set
        team_sets = thinkspace_team_team_sets
        if team_sets.empty?
          Thinkspace::Team::TeamSet.create(title: 'Default', default: true, space_id: self.id, user_id: 0)
        end
        default = team_sets.scope_default
        unless default.present?
          team_set         = team_sets.first
          team_set.default = true
          team_set.save
        end
      end

      def default_team_set
        ensure_default_team_set
        thinkspace_team_team_sets.scope_default
      end

      private

      def get_clone_associations(options={})
        clone_associations = [:thinkspace_common_space_space_types]  # add cloned space to space_space_types table
        clone_associations
      end

      def add_user_as_role(user, role)
        return if thinkspace_common_space_users.include?(user)
        thinkspace_common_space_users << Thinkspace::Common::SpaceUser.create(thinkspace_common_user: user, role: role, state: 'active')
      end

      def invitation_class; Thinkspace::Common::Invitation; end
      def user_class; Thinkspace::Common::User; end
      def space_user_class; Thinkspace::Common::SpaceUser; end
      def notification_mailer_class; Thinkspace::Common::NotificationMailer; end

      # ###
      # ### Delete Ownerable Data.
      # ###

      public

      def delete_all_ownerable_data!
        self.transaction do
          self.thinkspace_casespace_assignments.each do |assignment|
            assignment.delete_all_ownerable_data!
          end
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          self.thinkspace_casespace_assignments.each do |assignment|
            assignment.delete_ownerable_data(ownerables)
          end
        end
      end


    end
  end
end
