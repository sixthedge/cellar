module Thinkspace
  module Casespace
    class Assignment < ActiveRecord::Base
      def active; self.active?; end
      def due_at(ownerable=nil);     self.class.timetable_scope(ownerable).value(self.id, :due_at); end
      def release_at(ownerable=nil); self.class.timetable_scope(ownerable).value(self.id, :release_at); end
      def unlock_at(ownerable=nil);  self.class.timetable_scope(ownerable).value(self.id, :unlock_at); end
      totem_associations

      validates :title, presence: true, uniqueness: {scope: [:thinkspace_common_space]}

      def serializer_metadata(ownerable, so)
        phases                 = self.thinkspace_casespace_phases.accessible_by(so.current_ability, :read).scope_active
        hash                   = Hash.new
        hash[:count]           = phases.count
        hash[:completed]       = phases.scope_completed(ownerable).count
        hash[:has_assessments] = self.scope_phases_has_assessment.present?
        hash[:due_at]          = due_at(ownerable)
        hash[:release_at]      = release_at(ownerable)
        hash
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_not_deleted; where.not(state: 'deleted'); end

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      def self.scope_peer_assessment; where(bundle_type: 'assessment'); end

      def self.scope_assignment_association(space, current_ability, current_user)
        if space.user_sandbox?
          sandbox_space = space.thinkspace_common_sandbox_space
          raise SandboxError, "User sandbox space [id: #{space.id}] association [sandbox_space_id: space.sandbox_space_id] not found." if sandbox_space.blank?
          self.unscoped.where(space_id: [space.id, sandbox_space.id])
        else
          assignments = space.thinkspace_casespace_assignments.accessible_by(current_ability, :read)
          current_ability.can?(:update, space) ? assignments : assignments.scope_open(current_user)
        end
      end

      # ###
      # ### Timetable Scopes.
      # ###

      def self.timetable_scope(ownerables=nil); Thinkspace::Common::Timetable::Scope.new(self, ownerables); end

      def self.next_due_at(ownerables=nil)
        tts = timetable_scope(ownerables)
        tts.with_scope.scope_open(ownerables).minimum(tts.coalesce(:due_at))
      end

      def self.open_updated_ats(ownerables=nil)
        tts = timetable_scope(ownerables)
        tts.select_virtual(:updated_at).with_scope.scope_open(ownerables, tts)
      end

      def self.open_times(ownerables=nil)
        tts = timetable_scope(ownerables)
        tts.select_virtual(:release_at).select_virtual(:due_at).with_scope.scope_open(ownerables, tts)
      end

      def self.scope_open(ownerables=nil, tts=nil)
        (tts || timetable_scope(ownerables)).
        where_now('<=', :release_at).
        where_now('>=', :due_at).
        with_scope.
        scope_active
      end

      # ### Timetable helpers
      def get_or_set_timetable_for_self(options={})
        Thinkspace::Common::Timetable.find_or_create_timetable(self, options)
      end

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        state :deleted
        state :archived
        event :activate   do; transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
        event :to_deleted do; transitions to: :deleted; end
        event :archive    do; transitions to: :archived; end
      end

      def scope_phases_has_assessment
        thinkspace_casespace_phases.
        joins(:thinkspace_casespace_phase_components).
        where('thinkspace_casespace_phase_components.componentable_type = ?', 'Thinkspace::PeerAssessment::Assessment')
      end

      # ###
      # ### Helpers.
      # ###

      def get_space; thinkspace_common_space; end

      def peer_assessment?; self.bundle_type == 'assessment'; end

      def sandbox?; self.thinkspace_common_space.sandbox?; end

      def serializer_sandbox_for_thinkspace_common_space(current_user, current_ability, action)
        Thinkspace::Common::Space.accessible_by(current_ability, action).find_by(sandbox_space_id: self.space_id)
      end

      # ###
      # ### Team Helpers.
      # ###

      def get_teams(ownerable=nil)
        if ownerable.blank?
          teams = self.thinkspace_team_teams
        else
          case
          when ownerable.kind_of?(Thinkspace::Common::User)
            self.thinkspace_team_teams.scope_by_users(ownerable)
          when ownerable.kind_of?(Thinkspace::Team::Team)
            self.thinkspace_team_teams.scope_by_teams(ownerable)
          else
            raise AssignmentTeamError, "Ownerable class must be a user or team not #{ownerable.class.name.inspect}."
          end
        end
      end

      # ###
      # ### Phase Helpers.
      # ###

      def reorder_phase_positions
        phases = thinkspace_casespace_phases.sort('position')
        phases.each_with_index do |phase, index|
          i = index + 1
          phase.position = i
          phase.save
        end
      end

      class ScopeError          < StandardError; end
      class AssignmentTeamError < StandardError; end
      class SandboxError        < StandardError; end

      # ###
      # ### Phase State Helpers.
      # ###

      def get_user_phase_states(phases, ownerable, user, options={})
        get_phase_states(phases, ownerable, user, options)
      end

      def get_phase_states(phases, ownerable, user, options={})
        phase_states = Array.new
        phases.each do |phase|
          phase_states.push phase.get_phase_states(ownerable, user, options)
        end
        phase_states.flatten.uniq
      end

      # ###
      # ### Clone assignment
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          space                      = options[:space]  # specific space override
          options[:dictionary]      ||= get_clone_dictionary(options)
          clone_associations         = get_clone_associations(options)
          cloned_assignment          = clone_self(options, clone_associations)
          cloned_assignment.title    = get_clone_title(self.title, options)
          cloned_assignment.space_id = space.id  if space.present?
          cloned_assignment.inactivate
          clone_save_record(cloned_assignment)
          options.merge!(keep_title: true, is_full_clone: true)
          phases = thinkspace_casespace_phases.order('position')
          phases.each do |phase|
            phase.cyclone(options)
          end
          clone_assignment_resources(options)         if clone_include?(:clone_resources, options)
          cloned_assignment
        end
      end

      private

      def get_clone_associations(options={})
        clone_associations = []
        clone_associations.push(:thinkspace_common_space)  if is_full_clone?(options)
        clone_associations
      end

      # ###
      # ### Clone Helpers.
      # ###

      include Thinkspace::Resource::Concerns::Clone::Resources
      include Thinkspace::Team::Concerns::Clone::Teams

      def clone_assignment_resources(options={}); clone_record_resources(self, get_clone_dictionary(options), options); end

      public

      # ###
      # ### Delete Ownerable Data.
      # ###

      def delete_all_ownerable_data!
        self.transaction do
          self.thinkspace_casespace_phases.each do |phase|
            phase.delete_all_ownerable_data!
          end
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          self.thinkspace_casespace_phases.each do |phase|
            phase.delete_ownerable_data(ownerables)
          end
        end
      end

      def sync_rat
        return false unless settings.present?
        return false unless settings['rat']['sync'].present?
        return settings['rat']['sync']
      end

      # ###
      # ### Query Key
      # ###
      def query_key_for_timetables(record, ownerables=nil, options={})
        assignments_updated_at   = self.class.scope_open(ownerables).maximum(:updated_at) || :none
        phases_updated_at        = self.thinkspace_casespace_phases.phase_timetables_maximum_updated_at(ownerables) || :none
        ['assignment_timetables', assignments_updated_at, 'phase_timetables', phases_updated_at]
      end

      def self.query_key_for_timetables(scope, ownerables=nil, options={})
        assignments_updated_at = scope.scope_open(ownerables).maximum(:updated_at) || :none
        phase_ids              = scope.joins(:thinkspace_casespace_phases).pluck('thinkspace_casespace_phases.id')
        phases_updated_at      = Thinkspace::Casespace::Phase.where(id: phase_ids).phase_timetables_maximum_updated_at(ownerables) || :none
        ['assignment_timetables', assignments_updated_at, 'phase_timetables', phases_updated_at]
      end

      # ###
      # ### Export Ownerable Data.
      # ###
      def export_all_ownerable_data(options={})
        processor = Thinkspace::Casespace::Exporters::OwnerableData.new(assignments: self)
        processor.process
      end

      def export_ownerable_data(ownerables, options={})
        processor = Thinkspace::Casespace::Exporters::OwnerableData.new(assignments: self, ownerables: ownerables)
        processor.process
      end

    end
  end
end
