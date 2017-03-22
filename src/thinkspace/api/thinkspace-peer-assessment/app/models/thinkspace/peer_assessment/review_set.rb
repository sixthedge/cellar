module Thinkspace; module PeerAssessment
  # # review_set
  # - Type: **Model**
  # - Engine: **thinkspace-peer-assessment**
  class ReviewSet < ActiveRecord::Base
    totem_associations
    
    # ### States
    include AASM

    aasm column: :state do
      state :neutral, initial: true
      state :submitted
      state :ignored

      event :ignore do
        transitions from: [:neutral], to: :ignored
      end

      event :unignore do
        transitions from: [:ignored], to: :neutral, after: :unlock_phase_for_ownerable
      end

      event :submit do
        transitions from: [:neutral], to: :submitted
      end

      event :unlock do
        transitions from: [:submitted], to: :neutral, after: :unlock_phase_for_ownerable
      end
    end

    def status
      return 'complete' if submitted?
      return 'ignored' if ignored?
      return 'in-progress' if in_progress?
      return 'not started'
    end

    def in_progress?; thinkspace_peer_assessment_reviews.where.not(value: nil).count > 0; end


    def unlock_phase_for_ownerable
      ownerable = self.ownerable
      phase     = self.get_authable
      raise 'Cannot unlock a phase without a valid phase.' unless phase.present?
      raise 'Cannot unlock a phase without a valid ownerable.' unless ownerable.present?
      phase_state = Thinkspace::Casespace::PhaseState.find_or_create_by(ownerable: ownerable, phase_id: phase.id)
      phase_state.unlock_phase!
    end

    # ### Review Helpers
    def create_reviews
      team_set = thinkspace_peer_assessment_team_set
      return unless team_set.present?
      team = team_set.thinkspace_team_team
      return unless team
      users = team.thinkspace_common_users
      users = users.to_a # Important: Must `to_a` to not remove the relationship.
      users.delete(ownerable)
      users.each do |user|
        review = Thinkspace::PeerAssessment::Review.find_or_create_by(review_set_id: self.id, reviewable: user)
      end
    end

    # ### Helpers
    def get_team_set; thinkspace_peer_assessment_team_set; end
    def get_assessment; get_team_set.get_assessment; end
    def authable; get_assessment.authable; end
    def get_authable; authable; end
    def complete_phase_for_ownerable
      phase       = authable
      phase_state = phase.find_or_create_state_for_ownerable(ownerable)
      phase_state.complete_phase!
      phase_state
    end

    # ### Scopes
    # Ownerable_type and ID needed because of: https://github.com/rails/rails/issues/16983
    def self.scope_where_not_ownerable_ids(ownerables)
      ownerables = Array.wrap(ownerables)
      raise ScopeError "Ownerables must be present" if ownerables.blank?
      where.not(ownerable_id: ownerables.map(&:id))
    end

    def self.scope_by_team_sets(team_sets)
      where(thinkspace_peer_assessment_team_set: team_sets)
    end

    def self.scope_ignored; ignored; end
    def self.scope_submitted; submitted; end
    def self.scope_neutral; neutral; end

    class ScopeError < StandardError; end

  end
end; end;