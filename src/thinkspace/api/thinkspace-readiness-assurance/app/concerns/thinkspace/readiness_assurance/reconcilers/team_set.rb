module Thinkspace; module ReadinessAssurance; module Reconcilers
  class TeamSet

    # ### Thinkspace::ReadinessAssurance::Reconcilers::TeamSet
    # ----------------------------------------
    #
    # The primary function of this object is to:
    # - reassign all readiness_assurance/responses with a team ownerable to the new corresponding team


    attr_reader :team_set, :options, :phase, :assessment, :assignment, :delta

    # ### Initialization
    def initialize(team_set, options={})
      @team_set                   = team_set
      @options                    = options
      @phase                      = options[:phase]
      @assessment                 = options[:componentable]
      @assignment                 = @phase.thinkspace_casespace_assignment
      @delta                      = options[:delta]
    end

    # ### Processing
    def process
      reassign_team_responses
    end

    private

    # Changes the ownerable of all team responses to the new team, as saved in the delta object by the exploder
    def reassign_team_responses
      @delta[:teams].each do |tobj|
        response = get_response_by_team_id(tobj[:id])
        next if response.blank?
        if tobj[:deleted]
          next
        elsif tobj[:new]
          next
        else
          response.ownerable = get_team_by_id(tobj[:new_id])
          response.save
        end
      end
    end

    # ### Classes
    def user_class;     Thinkspace::Common::User;                         end
    def team_class;     Thinkspace::Team::Team;                           end
    def response_class; Thinkspace::ReadinessAssurance::Response;         end
    def mailer_class;   Thinkspace::ReadinessAssurance::AssessmentMailer; end

    # ### Helpers
    def get_response_by_team_id(id)
      response_class.find_by(ownerable_type: 'Thinkspace::Team::Team', ownerable_id: id, assessment_id: @assessment.id)
    end

    def get_team_by_id(id); team_class.find(id); end


  end
end; end; end
