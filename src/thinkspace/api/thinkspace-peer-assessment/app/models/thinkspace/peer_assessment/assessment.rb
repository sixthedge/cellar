module Thinkspace; module PeerAssessment
  # # assessment
  # - Type: **Model**
  # - Engine: **thinkspace-peer-assessment**
  class Assessment < ActiveRecord::Base
    totem_associations

    # ### States
    include AASM
   
    aasm column: :state do
      state :neutral, initial: true
      state :approved
      state :active

      event :activate, before: :activate_assessment do
        transitions from: :neutral, to: :active
      end

      event :approve do
        transitions to: :approved, after: :process_assessment
      end
    end

    # ### Helpers
    def self.create_assessment(assignment, assessment, team_set)
      self.transaction do
        authable         = assignment.thinkspace_common_space
        team_set         = team_set.clone_and_lock(authable)
        phase_assessment = create_assessment_phase(assignment, assessment)
        phase_overview   = create_assessment_overview_phase(assignment, assessment)
        team_set.add_teamables([phase_assessment, phase_overview])
      end
    end


    def self.create_assessment_phase(assignment, assessment)
      phase               = assessment_phase(assignment)
      assessment.authable = phase
      assessment.save
      create_phase_component(phase, assessment, 'peer-assessment', 'assessment')
      create_header_component(phase)
      phase
    end

    def self.create_assessment_overview_phase(assignment, assessment)
      phase    = assessment_overview_phase(assignment)
      overview = create_overview(phase, assessment)
      create_phase_component(phase, overview, 'peer-assessment-overview', 'overview')
      create_header_component(phase)
      phase
    end

    def self.create_overview(phase, assessment)
      Thinkspace::PeerAssessment::Overview.create(authable: phase, assessment_id: assessment.id)
    end

    def self.create_phase(options={})
      phase                   = Thinkspace::Casespace::Phase.new
      phase.assignment_id     = options[:assignment_id]
      phase.phase_template_id = options[:phase_template_id]
      phase.team_category_id  = options[:team_category_id]
      phase.title             = options[:title] || 'Peer Assessment Phase'
      phase.description       = options[:description] || 'Peer assessment description.'
      phase.state             = options[:state] || :inactive
      phase.default_state     = options[:default_state] || 'unlocked'
      phase.position          = options[:position] || 1
      phase.save
      phase
    end

    def self.assessment_overview_phase(assignment)
      options                     = Hash.new
      options[:assignment_id]     = assignment.id
      options[:phase_template_id] = assessment_overview_phase_template.id
      options[:team_category_id]  = Thinkspace::Team::TeamCategory.assessment.id
      options[:title]             = 'Peer Assessment Overview' # TODO: What should title be?
      options[:description]       = 'See the peer assessment overview here.' # TODO: What should the description be?
      options[:state]             = :active
      options[:default_state]     = 'locked'
      options[:position]          = 2
      create_phase(options)
    end

    def self.assessment_phase(assignment)
      options                     = Hash.new
      options[:assignment_id]     = assignment.id
      options[:phase_template_id] = assessment_phase_template.id
      options[:team_category_id]  = Thinkspace::Team::TeamCategory.assessment.id
      options[:title]             = 'Peer Assessment' # TODO: What should title be?
      options[:description]       = 'Take the peer assessment here.' # TODO: What should the description be?
      options[:state]             = :active
      options[:default_state]     = 'unlocked'
      options[:position]          = 1
      create_phase(options)
    end

    def self.create_header_component(phase); create_phase_component(phase, phase, 'casespace-phase-header', 'header'); end
    def self.create_submit_component(phase); create_phase_component(phase, phase, 'casespace-phase-submit', 'submit'); end
    def self.create_phase_component(phase, componentable, component_title, section)
      component = Thinkspace::Common::Component.find_by(title: component_title)
      raise "Component with title #{component_title.inspect} not found." if component.blank?
      phase_component = phase.thinkspace_casespace_phase_components.create(
        componentable: componentable,
        component_id:  component.id,
        section:       section
      )
      phase_component
    end

    def self.common_component
      Thinkspace::Common::Component.find_by(title: 'peer-assessment')
    end

    def self.assessment_phase_template
      Thinkspace::Casespace::PhaseTemplate.find_by(name: 'peer_assessment/assessment')
    end

    def self.assessment_overview_phase_template
      Thinkspace::Casespace::PhaseTemplate.find_by(name: 'peer_assessment/overview')
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

    def process_assessment
      # TODO: Re-add notify
      thinkspace_peer_assessment_team_sets.scope_approved.each { |team_set| team_set.mark_as_sent! }
    end

    def overview_phase
      phase      = authable
      assignment = phase.thinkspace_casespace_assignment
      phase_ids  = assignment.thinkspace_casespace_phases.scope_active.pluck(:id)
      overview   = Thinkspace::PeerAssessment::Overview.find_by(assessment_id: self.id)
      return unless overview.present?
      overview_phase = overview.authable
      raise "Cannot get a phase that is cross-assignment when unlocked a PeerAssessment::Assessment" unless phase_ids.include?(overview_phase.id)
      overview_phase
    end

    def notify_overview_unlocked_for_user(user)
      Thinkspace::PeerAssessment::AssessmentMailer.notify_overview_unlocked(self, user).deliver_now
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
