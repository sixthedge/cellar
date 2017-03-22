module Thinkspace; module PeerAssessment
  # # team_set
  # - Type: **Model**
  # - Engine: **thinkspace-peer-assessment**
  class TeamSet < ActiveRecord::Base
    totem_associations

    # ### States
    include AASM
   
    aasm column: :state do
      state :neutral, initial: true
      state :approved
      state :sent

      event :approve do
        transitions from: [:neutral], to: :approved, after: :ignore_review_sets
      end

      event :unapprove do
        transitions from: [:approved], to: :neutral, after: :unignore_review_sets
      end

      event :mark_as_sent do
        transitions from: [:approved], to: :sent
      end
    end

    def ignore_review_sets
      thinkspace_peer_assessment_review_sets.scope_neutral.each { |review_set| review_set.ignore! if review_set.may_ignore? }
    end

    def unignore_review_sets
      thinkspace_peer_assessment_review_sets.scope_ignored.each { |review_set| review_set.unignore! if review_set.may_unignore? }
    end

    # ### Helpers
    def get_assessment; thinkspace_peer_assessment_assessment; end

    # ### Scopes
    def self.scope_neutral; neutral; end
    def self.scope_approved; approved; end

    class ScopeError < StandardError; end

  end
end; end;