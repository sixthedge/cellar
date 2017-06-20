module Thinkspace; module PeerAssessment
  class Assessment < ActiveRecord::Base
    # Thinkspace::PeerAssessment::Assessment
    # ---
    totem_associations

    # ### States
    include AASM
   
    aasm column: :state do
      state :neutral, initial: true
      state :approved
      state :active

      event :activate do
        transitions from: :neutral, to: :active
      end

      event :approve do
        transitions to: :approved, after: :process_assessment
      end
    end

    def quantitative_items
      return [] unless value.has_key?('quantitative')
      value['quantitative']
    end

    def quantitative_items
      return [] unless value.has_key?('quantitative')
      value['quantitative']
    end

    def options
      value['options']
    end

    def assessment_type
      return nil unless options.present?
      options['type']
    end

    def is_balance_points?
      assessment_type == 'balance'
    end

    def get_points_per_member
      options.with_indifferent_access.dig(:points, :per_member) || 0.0
    end

    def get_min_max_score_for_reviews(number_of_reviews=0.0)
      min_score = 0.0
      max_score = 0.0
      quantitative_items.each do |item|
        dirt   = item.with_indifferent_access
        min    = dirt.dig(:settings, :points, :min)
        max    = dirt.dig(:settings, :points, :max)
        min_score += min
        max_score += max
      end
      max_allocated = get_points_per_member * number_of_reviews
      max_score     = max_allocated if max_score > max_allocated
      [min_score, max_score]
    end

    def activate_assessment
      self.transaction do
        team_set_teamable = authable.thinkspace_team_team_set_teamables.first
        raise "Cannot activate assessment [#{self.id}] without a valid team set teamble." unless team_set_teamable.present?
        team_set = team_set_teamable.thinkspace_team_team_set
        raise "Cannot activate assessment [#{self.id}] without a valid team set." unless team_set.present?
        authable.unassign_team_set # Remove all team sets from the phase.
        new_team_set  = team_set.clone_and_lock(authable)
        teamables = thinkspace_peer_assessment_overviews.map(&:authable).uniq
        teamables.push authable # All overview phases and assessment phase.
        new_team_set.add_teamables teamables
      end
    end

    def get_or_create_team_sets
      team_ids          = Thinkspace::Team::Team.scope_by_teamables(self.authable).pluck(:id)
      assessment_id     = self.id
      team_sets         = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: assessment_id, team_id: team_ids)
      existing_team_ids = team_sets.pluck(:team_id)
      create_team_ids   = team_ids - existing_team_ids
      create_team_ids.each { |id| Thinkspace::PeerAssessment::TeamSet.create(assessment_id: assessment_id, team_id: id) }
      team_sets.reload unless create_team_ids.empty?
      team_sets
    end

    def process_assessment
      thinkspace_peer_assessment_team_sets.scope_approved.each { |team_set| team_set.mark_as_sent! }
    end

    ## Serialized method to determine whether the current state of the 'value' column differs from the assessment template's.
    ## Used to prompt the user to create a new assessment template if they've made changes to their existing template.
    def modified_template
      if assessment_template_id.present?
        assessment_template = Thinkspace::PeerAssessment::AssessmentTemplate.find(assessment_template_id)

        return !(assessment_template.value == self.value)
      else
        return false
      end
    end

    # ###
    # ### Clone Assessment.
    # ###

    include ::Totem::Settings.module.thinkspace.deep_clone_helper

    def cyclone(options={})
      self.transaction do
        cloned_assessment       = clone_self(options)
        cloned_assessment.state = 'neutral'
        clone_save_record(cloned_assessment)
      end
    end

    # ###
    # ### Builder Abilities.
    # ### 
    def builder_abilities(abilities)
      if approved? || active?
        abilities[:team_based]    = false
        abilities[:team_category] = false
        abilities[:team_set]      = false
      end
      abilities
    end

  end
end; end
