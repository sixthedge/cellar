module Thinkspace; module ReadinessAssurance; module Creators 
  class Assignment < ::Thinkspace::Casespace::Creators::Base
    # Thinkspace::ReadinessAssurance::Creators::Assignment
    # ---
    attr_accessor :assessment

    def initialize(params)
      @params = params 
    end

    def generate
      ActiveRecord::Base.transaction do
        @assignment = create_assignment_from_params
        trat_phase  = create_assessment_phase(trat_assessment_template)
        irat_phase  = create_assessment_phase(irat_assessment_template)
        @trat_assessment = create_assessment(trat_phase, 'trat')
        @irat_assessment = create_assessment(irat_phase, 'irat')
      end

      @assignment
    end

    def create_assessment(phase, type)
      @assessment = assessment_class.create(
        authable: phase,
        settings: {
          ra_type: type
        },
        questions: []
      )
      create_header_component(phase)
      create_phase_component(phase, assessment, 'readiness-assurance', 'assessment')
      @assessment
    end

    def create_assessment_phase(template)
      options = get_assessment_phase_options(template)
      create_phase(options)
    end

    def get_assessment_phase_options(template)
      options                     = Hash.new
      options[:assignment_id]     = @assignment.id
      options[:phase_template_id] = template.id
      options[:team_category_id]  = Thinkspace::Team::TeamCategory.assessment.id
      options[:title]             = template.title
      options[:description]       = 'Readiness assurance default description.'
      options[:state]             = :active
      options[:default_state]     = 'unlocked'
      options[:position]          = 1
      options
    end

    def assessment_class; Thinkspace::ReadinessAssurance::Assessment; end

    def irat_assessment_template; Thinkspace::Casespace::PhaseTemplate.find_by(name: 'readiness_assurance_irat'); end
    def trat_assessment_template; Thinkspace::Casespace::PhaseTemplate.find_by(name: 'readiness_assurance_trat'); end

end; end; end; end

