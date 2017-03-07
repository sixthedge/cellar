module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :authorize_authable
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def update
            access_denied_state_error :update if @assessment.active?
            @assessment.value = params_root[:value]
            @assessment.assessment_template_id = params_association_id(:assessment_template_id)
            # if @assessment.save
            #   controller_render_no_content
            # else
            @assessment.save ? controller_render(@assessment) : controller_render_error(@assessment)
            # end
          end

          def activate
            access_denied_state_error :activate unless @assessment.may_activate?
            phase = @assessment.authable
            teams = phase.thinkspace_team_teams
            access_denied "No teams are assigned to phase [#{phase.id}].", 'There are no teams assigned to this phase.  Please assign a team and try again.' if teams.blank?
            @assessment.activate!
            controller_render(@assessment)
          end

          def approve
            access_denied_state_error :approve unless @assessment.may_approve?
            @assessment.approve!
            controller_render(@assessment.thinkspace_peer_assessment_team_sets)
          end

          def approve_team_sets
            @team_sets = @assessment.thinkspace_peer_assessment_team_sets
            @team_sets.scope_neutral.update_all(state: 'approved')
            Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: @team_sets.pluck(:id)).scope_neutral.update_all(state: 'ignored')
            controller_render(@team_sets)
          end

          def teams
            teams = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable)
            controller_render(teams)
          end

          def review_sets
            team_id     = params[:team_id]
            team        = Thinkspace::Team::Team.find_by(id: team_id)
            authorize! :update, team.authable
            team_set    = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
            review_sets = team_set.thinkspace_peer_assessment_review_sets
            controller_render(review_sets)
          end

          def team_sets
            team_ids          = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable).pluck(:id)
            assessment_id     = @assessment.id
            team_sets         = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: assessment_id, team_id: team_ids)
            existing_team_ids = team_sets.pluck(:team_id)
            create_team_ids   = team_ids - existing_team_ids
            create_team_ids.each { |id| Thinkspace::PeerAssessment::TeamSet.create(assessment_id: assessment_id, team_id: id) }
            team_sets.reload unless create_team_ids.empty?
            controller_render(team_sets)
          end

          def progress_report

            teams       = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable)
            team_sets   = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: @assessment.id, team_id: teams.pluck(:id))
            review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: team_sets.pluck(:id))

            data = { team_sets: Array.new }

            team_sets.each do |team_set|
              team         = teams.find_by(id: team_set.team_id)
              num_total    = team_set.thinkspace_team_team.thinkspace_common_users.count
              num_complete = team_set.thinkspace_peer_assessment_review_sets.to_a.count { |rs| rs.status == 'complete' }

              team_set_data = {
                id:           team_set.id,
                title:        team_set.thinkspace_team_team.title,
                num_total:    num_total,
                num_complete: num_complete,
                num_ignored:  num_total - num_complete,
                state:        team_set.state,
                color:        team_set.thinkspace_team_team.color,
                review_sets:  Array.new
              }

              team.thinkspace_common_users.order(:first_name, :last_name).each do |user|

                review_set = review_sets.find_by(ownerable: user, team_set_id: team_set.id)
                id         = if review_set.present? then review_set.id     else nil           end
                state      = if review_set.present? then review_set.state  else 'neutral'     end
                status     = if review_set.present? then review_set.status else 'not started' end

                team_set_data[:review_sets] << {
                  id:             id,
                  name:           user.full_name,
                  color:          user.color,
                  state:          state,
                  status:         status,
                  ownerable_id:   user.id,
                  ownerable_type: 'thinkspace/common/user'
                }
              end

              data[:team_sets] << team_set_data
            end
            data[:team_sets] = data[:team_sets].sort { |a,b| a[:title] <=> b[:title] }

            data[:complete] = {
              review_sets: review_sets.to_a.count { |rs| rs.status == 'complete' },
              team_sets:   data[:team_sets].count { |tsd| tsd[:num_complete] == tsd[:num_total] }
            }

            data[:total] = {
              review_sets: Thinkspace::Team::TeamUser.where(team_id: teams.pluck(:id)).count,
              team_sets:   team_sets.count
            }

            controller_render_json(data) 

          end


          private

          def access_denied(message, user_message='')
            raise_access_denied_exception(message, self.action_name.to_sym, @user || controller_model_class_name, user_message: user_message)
          end

          def authorize_authable
            authorize! :update, @assessment.authable
          end

          def set_state_error_variables
            @model        = @assessment
            @model_name   = 'an assessment'
            @model_class  = @model.class.name
          end

        end
      end
    end
  end
end
