module Thinkspace; module PeerAssessment
  class TeamSet < ActiveRecord::Base
    # Thinkspace::PeerAssessment::TeamSet
    # --
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
        transitions from: [:approved], to: :sent, after: :notify_results_unlocked
      end
    end

    def ignore_review_sets
      thinkspace_peer_assessment_review_sets.scope_neutral.each { |review_set| review_set.ignore! if review_set.may_ignore? }
    end

    def unignore_review_sets
      thinkspace_peer_assessment_review_sets.scope_ignored.each { |review_set| review_set.unignore! if review_set.may_unignore? }
    end

    def reset_quantitative_data
      thinkspace_peer_assessment_review_sets.each { |review_set| review_set.reset_quantitative_data }
    end

    def notify_results_unlocked
      assessment = get_assessment
      self.thinkspace_peer_assessment_review_sets.each do |review_set|
        Thinkspace::PeerAssessment::AssessmentMailer.notify_results_unlocked(assessment, review_set.ownerable).deliver_now
      end
    end
    handle_asynchronously :notify_results_unlocked


    # ### Helpers
    def get_assessment; thinkspace_peer_assessment_assessment; end
    def get_or_create_review_sets
      Thinkspace::Team::Team.find(team_id).thinkspace_common_users.each do |user|
        Thinkspace::PeerAssessment::ReviewSet.find_or_create_by(ownerable: user, team_set_id: self.id)
      end
      review_sets = self.thinkspace_peer_assessment_review_sets
    end

    def self.scope_neutral; neutral; end
    def self.scope_approved; approved; end

    class ScopeError < StandardError; end

  end
end; end;