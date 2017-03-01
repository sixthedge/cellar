module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller


          def progress_report
            set_trat_assessment
            controller_render_json(@assessment.progress_report)
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

        end
      end
    end
  end
end
