module Thinkspace; module PeerAssessment; module Creators 
  # # assignment
  # - Type: **Class**
  # - Engine: **thinkspace-peer-assessment**
  class Assignment < ::Thinkspace::Casespace::Creators::Base

    attr_accessor :assessment

    def initialize(params)
      @params = params 
    end

    def generate
      ActiveRecord::Base.transaction do
        @assignment      = create_assignment_from_params
        phase            = create_assessment_phase
        @assessment      = create_assessment(phase)
      end

      @assignment
    end

    def create_assessment(phase)
      @assessment = assessment_class.create(authable: phase)
      create_header_component(phase)
      create_phase_component(phase, assessment, 'peer-assessment', 'assessment')
      @assessment
    end

    def create_assessment_phase
      options = get_assessment_phase_options
      create_phase(options)
    end

    def get_assessment_phase_options
      options                     = Hash.new
      options[:assignment_id]     = @assignment.id
      options[:phase_template_id] = assessment_phase_template.id
      options[:team_category_id]  = Thinkspace::Team::TeamCategory.assessment.id
      options[:title]             = 'Peer Assessment'
      options[:description]       = 'Take the peer assessment here.'
      options[:state]             = :active
      options[:default_state]     = 'unlocked'
      options[:position]          = 1
      options
    end

    def assessment_class; Thinkspace::PeerAssessment::Assessment; end

    def assessment_phase_template; Thinkspace::Casespace::PhaseTemplate.find_by(name: 'peer_assessment/assessment'); end

end; end; end; end

