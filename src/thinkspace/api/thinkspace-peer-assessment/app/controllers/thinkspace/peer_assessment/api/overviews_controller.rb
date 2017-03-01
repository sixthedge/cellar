module Thinkspace
  module PeerAssessment
    module Api
      class OverviewsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options
        before_action :can_read_overview, only: [:view]

        def show
          controller_render(@overview)
        end

        def view
          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :reviews
            anonymous_reviews
          end
        end

        private

        def can_read_overview
          # TODO: Should TAA handle this automatically?
          phase       = @overview.authable
          ownerable   = totem_action_authorize.params_ownerable
          phase_state = phase.find_or_create_state_for_ownerable(ownerable)
          access_denied "Cannot access an overview for a locked phase.", user_message: "Cannot access a locked overview phase." if phase_state.locked?
        end

        def anonymous_reviews
          ownerable  = totem_action_authorize.params_ownerable
          assessment = @overview.thinkspace_peer_assessment_assessment
          phase      = assessment.authable
          teams      = Thinkspace::Team::Team.users_teams(phase, ownerable)
          access_denied "No teams found on phase for ownerable." unless teams.present?
          team      = teams.first
          access_denied "No team found on phase for ownerable." unless team.present?
          team_set =  Thinkspace::PeerAssessment::TeamSet.find_by(team_id: team.id, assessment_id: assessment.id)
          access_denied "No team set found for team_id [#{team.id}] and assessment_id [#{assessment.id}]" unless team_set.present?
          # Ownerable_type and ID needed because of: https://github.com/rails/rails/issues/16983
          review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: team_set.id, ownerable_type: ownerable.class.name).scope_where_not_ownerable_ids(ownerable).scope_sent
          access_denied "No review sets found for team_set_id [#{team_set.id}]" unless review_sets.present?
          review_set_ids = review_sets.pluck(:id)
          reviews        = Thinkspace::PeerAssessment::Review.where(review_set_id: review_set_ids, reviewable: ownerable)
          json           = Thinkspace::PeerAssessment::Review.generate_anonymized_review_json(assessment, reviews)
          controller_render_json(json)
        end

        def access_denied(message, options={})
          raise_access_denied_exception(message, totem_action_authorize.action, @overview, options)
        end

      end
    end
  end
end
