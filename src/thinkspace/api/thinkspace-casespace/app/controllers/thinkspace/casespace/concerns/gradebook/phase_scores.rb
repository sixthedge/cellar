module Thinkspace
  module Casespace
    module Concerns
      module Gradebook
        module PhaseScores

          private

          # ###
          # ### Main Phase Scores Methods
          # ###

          def assignment_roster_scores(assignment, options={}); get_assignment_roster_scores(assignment, options); end

          def phase_roster_scores(phase, options={})
            phase.team_ownerable? ? get_phase_roster_scores_by_team(phase, options) : get_phase_roster_scores_by_user(phase, options)
          end

          # ###
          # ### Assignment Roster.
          # ###

          def get_assignment_roster_scores(assignment, options)
            users      = score_gradebook_users(assignment)
            phases     = assignment.thinkspace_casespace_phases.accessible_by(current_ability, :read).order(:position)
            all_scores = Array.new
            all_phases = Array.new
            phases.each do |phase|
              phase_scores = phase_roster_scores(phase)
              all_phases.push phase_scores[:phase]
              all_scores.push phase_scores[:scores]
            end
            {phases: all_phases, scores: all_scores}
          end

          # ###
          # ### Phase Roster.
          # ###

          def get_phase_roster_scores_by_team(phase, options)
            users      = score_gradebook_users(phase.thinkspace_casespace_assignment)
            all_scores = Array.new
            users.each do |user|
              teams = phase.get_teams(user)
              user_hash = {
                user_id:        user.id,
                user_label:     gradebook_user_label(user),
                phase_id:       phase.id,
                phase_position: phase.position,
                score:          BigDecimal(0),
                state:          phase.default_state,
                team_ownerable: true,
                team_count:     teams.length,
                team_id:        0,
                team_label:     'no teams',
              }
              if teams.blank?
                all_scores.push user_hash
                next
              end
              teams.each do |team|
                phase_state = phase.find_or_create_state_for_ownerable(team, current_user)
                team_hash = {
                    score:      phase_state.score,
                    state:      phase_state.current_state,
                    state_id:   phase_state.id,
                    team_id:    team.id,
                    team_label: team.title,
                  }
                all_scores.push user_hash.merge(team_hash)
              end
            end
            {phase: get_phase_hash(phase), scores: all_scores}
          end

          def get_phase_roster_scores_by_user(phase, options)
            users      = score_gradebook_users(phase.thinkspace_casespace_assignment)
            all_scores = Array.new
            users.each do |user|
              phase_state = phase.find_or_create_state_for_ownerable(user, current_user)
              user_hash = {
                user_id:        user.id,
                user_label:     gradebook_user_label(user),
                phase_id:       phase.id,
                phase_position: phase.position,
                score:          phase_state.score,
                state:          phase_state.current_state,
                state_id:       phase_state.id,
              }
              all_scores.push user_hash
            end
            {phase: get_phase_hash(phase), scores: all_scores}
          end

          # ###
          # ### Helpers.
          # ###

          def get_roster_sum_ownerables_phase_scores(phase, ownerables)
            phase_states = get_roster_ownerables_phase_states(phase, ownerables)
            phase_states.to_ary.sum(&:score)
          end

          def get_roster_ownerables_phase_states(phase, ownerables)
            phase.thinkspace_casespace_phase_states.where(ownerable: ownerables)
          end

          def score_gradebook_users(assignment=@assignment)
            assignment.
              thinkspace_common_space.
              thinkspace_common_users.
              scope_active.
              accessible_by(current_ability, :gradebook)  # accessible_by must be applied to the users association
          end

          def gradebook_user_label(user); user.title; end

          def get_phase_hash(phase)
            {
              id:             phase.id,
              title:          phase.title,
              position:       phase.position,
              team_ownerable: phase.team_ownerable?,
            }
          end

        end
      end
    end
  end
end
