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
        irat_phase  = create_assessment_phase(irat_assessment_template)
        trat_phase  = create_assessment_phase(trat_assessment_template, 'trat')
        assign_teams(trat_phase)
        @irat_assessment = create_assessment(irat_phase, 'irat', false)
        @trat_assessment = create_assessment(trat_phase, 'trat', false)
      end

      @assignment
    end

    def create_assignment_from_params
      assignment_type_id = params_association_path_id('thinkspace/casespace/assignment_type_id')
      space_id           = params_association_path_id('thinkspace/common/space_id')

      model = assignment_class.new(assignment_type_id: assignment_type_id, space_id: space_id, state: :inactive, settings: {rat: {sync: true}})
      model.save(validate: false) # skip validations
      model
    end

    def create_assessment(phase, type, ifat)
      @assessment = assessment_class.create(
        authable: phase,
        settings: {
          ra_type: type,
          questions: {
            type:          'multiple_choice',
            random:        false,
            ifat:          ifat,
            justification: true
          },
          scoring: {
            correct:           5,
            attempted:         1,
            no_answer:         0,
            incorrect_attempt: -1
          }
        },
        questions: []
      )
      create_header_component(phase)
      create_phase_component(phase, assessment, 'readiness-assurance', 'rat')
      create_submit_component(phase)
      @assessment
    end

    def create_assessment_phase(template, type='irat')
      options = get_assessment_phase_options(template, type)
      create_phase(options)
    end

    def assign_teams(phase)
      assignment                          = phase.thinkspace_casespace_assignment
      space                               = assignment.get_space
      team_set                            = space.default_team_set
      phase.team_category_id = Thinkspace::Team::TeamCategory.collaboration
      Thinkspace::Team::TeamSetTeamable.create(team_set_id: team_set.id, teamable: assignment)
    end

    def get_assessment_phase_options(template, type)
      options                     = Hash.new
      options[:assignment_id]     = @assignment.id
      options[:phase_template_id] = template.id
      options[:team_category_id]  = Thinkspace::Team::TeamCategory.collaboration.id if type == 'trat'
      options[:title]             = template.title
      options[:description]       = 'Readiness assurance default description.'
      options[:state]             = :active
      options[:default_state]     = 'unlocked'
      options[:position]          = 1
      options[:settings]          = {
        validation: {validate: true},
        phase_score_validation: {numericality: {allow_blank: false, greater_than_or_equal_to: 1, less_than_or_equal_to: 50000, decimals: 0}},
        actions:    {submit: {class: "ra_#{type}_submit", state: 'complete', auto_score: {score_with: 'ra_auto_score'}}}
      }
      options
    end

    def assessment_class; Thinkspace::ReadinessAssurance::Assessment; end

    def irat_assessment_template; Thinkspace::Casespace::PhaseTemplate.find_by(name: 'readiness_assurance_irat'); end
    def trat_assessment_template; Thinkspace::Casespace::PhaseTemplate.find_by(name: 'readiness_assurance_trat'); end

end; end; end; end

