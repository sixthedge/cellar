module Thinkspace
  module Casespace
    module Concerns
      module Authorize
        module Markup

          include Phases

          def action_authorize!(phase=record_authable, ownerable=record_ownerable, view_ids=params_view_ids)
            super
            # Do not do any additional authorization if superuser.
            return# if current_user.superuser?
            # #
            # commenterable = current_record.commenterable
            # if commenterable.class.name == team_class
            #   authorize_current_user_is_on_collaboration_team(phase, commenterable) if phase_is_team_ownerable?(phase)
            # else
            #   authorize_current_user_is_user(phase, commenterable) unless can_update_phase?
            # end
            # debug_message('markup', "authorized markup commenterable.")  if debug?

          end

        end
      end
    end
  end
end
