module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class TimersController < ::Totem::Settings.class.thinkspace.authorization_api_controller

          def cancel
            validate_space
            id = get_timer_id
            access_denied "Timer cancel id is blank in params." if id.blank?
            se = get_timer_server_event(id)
            access_denied "Server event record with id #{se_id.inspect} not found." if se.blank?
            se_auth = se.authable
            access_denied "Server event id #{id.inspect} authable is blank." if se_auth.blank?
            access_denied "Cannot update authable '#{se_auth.class.name}.#{se_auth.id}'." unless can?(:update, se_auth)
            publish_timer_cancel(se, id)
            controller_render_no_content
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin
          include ::Thinkspace::PubSub::TimerHelpers

          def get_timer_id; timer_params[:id]; end

        end
      end
    end
  end
end
