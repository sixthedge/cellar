module Thinkspace
  module Casespace
    class PhaseState < ActiveRecord::Base
      def title; self.ownerable.title; end
      totem_associations
      has_paper_trail
      include AASM

      validates_presence_of :thinkspace_casespace_phase, :ownerable

      def score
        phase_score = self.thinkspace_casespace_phase_score
        phase_score.present? ? phase_score.score : BigDecimal(0)
      end

      def serializer_metadata(ownerable, so)
        phase             = self.thinkspace_casespace_phase
        hash              = Hash.new
        hash[:release_at] = phase.release_at(ownerable)
        hash[:due_at]     = phase.due_at(ownerable)
        hash[:unlock_at]  = phase.unlock_at(ownerable)
        hash
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_by_ownerable_type(type); where(ownerable_type: type); end
      def self.scope_by_ownerable_type_and_ids(type, ids); where(ownerable_type: type, ownerable_id: ids); end
      def self.scope_by_team_ownerable_ids(ids); scope_by_ownerable_type_and_ids('Thinkspace::Team::Team', ids); end
      def self.scope_by_user_ownerable_ids(ids); scope_by_ownerable_type_and_ids('Thinkspace::Common::User', ids); end

      def self.scope_by_not_ownerable_type_and_ids(type, ids); where.not(ownerable_type: type, ownerable_id: ids); end
      def self.scope_by_not_team_ownerable_ids(ids); scope_by_not_ownerable_type_and_ids('Thinkspace::Team::Team', ids); end
      def self.scope_by_not_user_ownerable_ids(ids); scope_by_not_ownerable_type_and_ids('Thinkspace::Common::User', ids); end

      def self.scope_locked; scope_by_state('locked'); end
      def self.scope_completed; scope_by_state('completed'); end
      def self.scope_by_state(state); where(current_state: state); end

      # ###
      # ### AASM
      # ###

      aasm column: :current_state do
        state :neutral, initial: true
        state :locked
        state :unlocked
        state :completed

        event :lock_phase do
          transitions to: :locked
        end

        event :unlock_phase do
          transitions to: :unlocked
        end

        event :complete_phase do
          transitions to: :completed
        end
      end

      # ### Event helpers
      def can_lock_phase?; true; end
      def can_unlock_phase?; may_unlock_phase?; end
      def can_complete_phase?; may_complete_phase?; end


    end
  end
end
