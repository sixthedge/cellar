module Thinkspace
  module Casespace
    module Concerns
      module Authorize
        module Phases

            public

            # ##################################################### #
            # Custom Action (e.g. platform specific) Related Methods.
            # ##################################################### #

            def get_assignment_phases
              @_assignment_phases ||= begin
                phase      = params_authable
                assignment = get_phase_assignment(phase)
                assignment.thinkspace_casespace_phases
              end
            end

            def get_carry_forward_elements(names)
              return [] if names.blank?
              names    = [names].flatten
              contents = content_class.where(authable: get_assignment_phases)
              element_class.where(componentable: contents, name: names)
            end

            def get_carry_forward_element_map_and_responses(names)
              # TODO: Ensure that params_ownerable is authorized correctly.
              phase = params_authable
              case
              when can_update_phase?
                ownerable = params_ownerable
              when (phase.peer_review? && (params_ownerable != current_user))
                has_common = !Thinkspace::Team::Team.users_common_teams(phase, [params_ownerable, current_user]).empty?
                ownerable  = has_common ? params_ownerable : current_user
              else
                ownerable = current_user
              end

              elements      = get_carry_forward_elements(names)
              element_map   = Hash.new
              phase_teams   = Hash.new
              all_responses = Array.new
              elements.each do |element|
                name  = element.name
                phase = element.authable
                if phase_is_team_ownerable?(phase)
                  teams = (phase_teams[phase.id] ||= team_class.scope_by_teamables(phase).scope_by_users(ownerable))
                  element_responses = element.thinkspace_input_element_responses.where(ownerable: teams)
                else
                  element_responses = element.thinkspace_input_element_responses.where(ownerable: ownerable)
                end
                ids = element_responses.map(&:id)
                element_map[name] ||= Array.new
                element_map[name] += ids
                all_responses     += element_responses
              end
              [element_map, all_responses]
            end

            private

            # ###
            # ### Method overrides required by totem_action_authorize!.
            # ###
            def authorize_authable_classes;  phase_class; end               # Classes allowed to be an 'authable'.
            def authorize_ownerable_classes; [user_class, team_class]; end  # Classes allowed to be an 'ownerable'.

            # ###
            # ### Main authorize processing (and method override).
            # ###

            def action_authorize!(phase=record_authable, ownerable=record_ownerable, view_ids=params_view_ids)
              if phase.blank?
                phase = params_authable
                access_denied("Phase params authable is blank.")  if phase.blank?
                @can_update_phase = can?(:update, phase)
              else
                @can_update_phase = can_update_record_authable?
              end

              case
              when authorize_phase_only?(phase)
                if action == :submit
                  ownerable = params_ownerable.present? && params_ownerable.instance_of?(team_class) ? params_ownerable : current_user
                else
                  ownerable = current_user
                end
                authorize_phase(phase, ownerable)
                if action == :load
                  valid_assignment = modify_or_read_assignment(phase, ownerable)
                  valid_phase      = modify_or_read_phase(phase, ownerable)
                  set_authable_ability(
                    peer_review_users: phase_user_can_peer_review_users?(phase, ownerable),
                    peer_review_teams: phase_user_can_peer_review_teams?(phase, ownerable),
                    modify_assignment: valid_assignment[:modify],
                    modify_phase:      valid_phase[:modify],
                    read_assignment:   valid_assignment[:read],
                    read_phase:        valid_phase[:read]
                  )
                end
              when authorize_phase_peer_review?
                ownerable = params_ownerable  if ownerable.blank?
                access_denied(phase, "Record and params ownerables are blank.")  if ownerable.blank?
                authorize_phase(phase, current_user)
                authorize_phase_ownerable(phase, ownerable)
                authorize_phase_view_ids(phase, ownerable)  if is_view?
              else
                ownerable = params_ownerable  if ownerable.blank?
                access_denied(phase, "Record and params ownerables are blank.")  if ownerable.blank?
                can_update_phase? ? set_ownerable_abilities_for_user(ownerable) : authorize_phase_ownerable(phase, ownerable)
                authorize_phase_ownerable(phase, ownerable)  unless can_update_phase?
                authorize_phase(phase, ownerable)
                authorize_phase_view_ids(phase, ownerable)  if is_view?
              end
            end

            def authorize_phase_only?(phase)
              current_record.present? and (current_record.class == phase_class || current_record.class == assignment_class)
            end

            def authorize_phase_peer_review?
              sub_action == :peer_review_users || sub_action == :peer_review_teams
            end

            # Classes used in this module.
            def user_class;  Thinkspace::Common::User; end
            def team_class;  Thinkspace::Team::Team; end
            def phase_class; Thinkspace::Casespace::Phase; end
            def assignment_class; Thinkspace::Casespace::Assignment; end
            def observation_list_class; @_obs_list_class ||= 'Thinkspace::ObservationList::List'.safe_constantize; end
            def observation_note_class; @_obs_list_note_class ||= 'Thinkspace::ObservationList::ObservationNote'.safe_constantize; end

            def content_class;  Thinkspace::Html::Content; end
            def response_class; Thinkspace::InputElement::Response; end
            def element_class;  Thinkspace::InputElement::Element; end

            # ################################### #
            # Authable (e.g phase).
            # ################################### #

            def authorize_phase(phase, ownerable)
              unless can_update_phase?
                authorize_phase_active(phase)
                # => Dates do not need to be checked (unless one is added in the future) on read requests.
                # => Dates only need to be checked when modifying (input_elements update, etc.)
                authorize_phase_dates(phase, ownerable)  unless skip_phase_date_check? || is_read?
                authorize_phase_state(phase, ownerable)  unless skip_phase_state_check?
              end
            end

            # A phase observation list's observations (and associated observation notes) are combined into
            # a single list and access may be allowed to any phase's list regardless of dates.
            # In the future this could be changed to match different criteria
            # (e.g. only on certain phase states, read only on 'locked' phases, etc.).
            def skip_phase_date_check?
              return false if observation_list_class.blank?
              model_class == observation_list_class || model_class == observation_note_class
            end

            def skip_phase_state_check?
              skip_phase_date_check?
              # skip if is_view, is carry_forward
            end

            # ###
            # ### Phase checks.
            # ###

            def authorize_phase_active(phase)
              assignment = get_phase_assignment(phase)
              access_denied(phase, "Is not active.")  unless assignment.active?
            end

            def authorize_phase_dates(phase, ownerable)
              assignment = get_phase_assignment(phase)
              release_at = phase.release_at(ownerable)
              due_at     = phase.due_at(ownerable)
              access_denied(phase, "Phase release_at is blank.")  if release_at.blank?
              access_denied(phase, "Phase due_at is blank.")      if due_at.blank?
              now = Time.now.utc
              access_denied(phase, "Phase is not available until release_at", user_message: "Case is not available until #{fmt_time(release_at)}.")  unless release_at <= now
              access_denied(phase, "Phase is past due.", user_message: "Phase is past the due date #{fmt_time(due_at)}.")  unless due_at >= now
              debug_message('phase dates', "authorized phase dates [now: #{now}] [release_at: #{release_at}] [due_at: #{due_at}].")  if debug?
            end

            def authorize_phase_state(phase, ownerable, valid_states=nil)
              access_denied(phase, "Ownerable is blank in authorize_phase_state.")  if ownerable.blank?
              valid_states ||= (is_read? ? read_phase_states_allowed : modify_phase_states_allowed)
              state = phase.find_or_create_state_for_ownerable(ownerable, current_user)
              # Allow peer review to see locked phases/carry forward of a team member.
              access_denied(phase, "Invalid phase state #{state.inspect}.") if !valid_states.include?(state.current_state) && !is_view? && (action != :carry_forward)
              debug_message('phase states', "authorized phase state [current_state: #{state.current_state.inspect} id=#{state.id}].")  if debug?
            end

            def modify_or_read_assignment(phase, ownerable)
              return {modify: true, read: true} if can_update_phase?
              assignment = get_phase_assignment(phase)
              return {modify: false, read: false} if assignment.blank?
              valid_dates(assignment, ownerable)
            end

            def modify_or_read_phase(phase, ownerable)
              return {modify: true, read: true} if can_update_phase?
              valid_dates(phase, ownerable)
            end

            def valid_dates(record, ownerable)
              validity          = Hash.new
              release_at        = record.release_at(ownerable)
              due_at            = record.due_at(ownerable)
              now               = Time.now.utc
              is_released       = release_at.present? && release_at <= now
              is_past_due       = due_at <= now
              validity[:modify] = is_released && !is_past_due
              validity[:read]   = is_released
              validity
            end

            def read_phase_states_allowed;   phase_class.read_states;       end
            def modify_phase_states_allowed; phase_class.modify_states;     end
            def admin_only_phase_states;     phase_class.admin_only_states; end

            # ################################### #
            # Ownerable.
            # ################################### #

            # CAUTION: If the ownerable is not the current user, cannot use 'current_ability'
            #          to validate an ownerable's abilities (e.g. cannot use: can?, authorize!, etc.).
            def authorize_phase_ownerable(phase, ownerable)
              case
              when team_ownerable_phase_user_request?(phase, ownerable)
                authorize_current_user_is_user(phase, ownerable)
                authorize_user_is_a_phase_user(phase, ownerable)
              when phase_is_team_ownerable?(phase)
                authorize_phase_team_ownerable(phase, ownerable)
              else
                authorize_phase_user_ownerable(phase, ownerable)
              end
            end

            # A team based phase, but really a user based request e.g. a user's phase collaboration teams.
            def team_ownerable_phase_user_request?(phase, ownerable)
              action == :teams_view && sub_action == :collaboration_teams && phase_is_team_ownerable?(phase)
            end

            # Current user must be for a team ownerable:
            # * On the collaboration team.
            # * On a collaboration team peer reviewing another collaboration team.
            # * Can read all phase collboration teams.
            def authorize_phase_team_ownerable(phase, team)
              access_denied(phase, "Phase team ownerable is not a team but [#{team.class.name}].") unless team.instance_of?(team_class)
              authorize_team_is_a_phase_team(phase, team)
              is_on_team = false
              unless can_read_all?
                case
                when sub_action == :peer_review_teams
                  authorize_current_user_on_or_can_view_team(phase, team)
                else
                  authorize_current_user_is_on_team(phase, team)
                  is_on_team = true
                end
              end
              debug_message('phase ownerable', "authorized 'team' ownerable [#{team.class.name} #{msg_id team}.")  if debug?
              set_ownerable_ability(create: is_on_team, update: is_on_team, destroy: is_on_team)
              debug_message('team ability', "user action team ability set to #{is_on_team.inspect}.")  if debug?
            end

            def authorize_phase_user_ownerable(phase, user)
              access_denied(phase, "Phase user ownerable is not a user but [#{user.class.name}].")  unless user.instance_of?(user_class)
              authorize_user_is_a_phase_user(phase, user)
              unless can_read_all?
                if phase.peer_review?
                  authorize_current_user_can_view_user(phase, user)
                else
                  authorize_current_user_is_user(phase, user)
                end
              end
              debug_message('phase ownerable', "authorized 'user' ownerable #{msg_class_id user}.")  if debug?
              set_ownerable_abilities_for_user(user)
              debug_message('user ability', "user action ability set to #{is_same_record?(current_user, user)}.")  if debug?
            end

            def authorize_current_user_is_user(phase, user)
              valid = is_same_record?(current_user, user)
              access_denied(phase, "Ownerable #{msg_id user} is not the current user.")  unless valid
              debug_message('current user', "authorized user #{msg_id user} is current user.")  if debug?
            end

            def authorize_user_is_a_phase_user(phase, user)
              return if user.superuser?
              valid = phase.get_space.is_space_user?(user)
              access_denied(phase, "User #{msg_id user} is not a phase user.")  unless valid
              debug_message('phase user', "authorized user #{msg_id user} is phase #{msg_id phase} user.")  if debug?
            end

            def authorize_team_is_a_phase_team(phase, team)
              valid = phase.thinkspace_team_teams.scope_by_teams(team).exists?
              if !valid  # if not valid, check if member of an assignment team for this phase
                assignment = get_phase_assignment(phase)
                valid      = assignment.thinkspace_team_teams.scope_by_teams(team).exists?
              end
              access_denied(phase, "Team #{msg_id team} is not associated with phase #{msg_id phase}].") unless valid
              debug_message('phase team', "authorized team #{msg_id team} is phase #{msg_id phase} team.")  if debug?
            end

            def authorize_current_user_on_or_can_view_team(phase, team)
              valid = phase_user_on_team?(phase, current_user, team) || phase_user_view_team?(phase, current_user, team)
              access_denied(phase, "User #{msg_id current_user} is not on and cannot view team #{msg_id team}.")  unless valid
              debug_message('team view', "authorized user #{msg_id current_user} is on or can view team #{msg_id team}.")  if debug?
            end

            def authorize_current_user_is_on_team(phase, team)
              valid = phase_user_on_team?(phase, current_user, team)
              access_denied(phase, "User #{msg_id current_user} is not on team #{msg_id team}.")  unless valid
              debug_message('team member', "authorized user #{msg_id current_user} on team #{msg_id team}.")  if debug?
            end

            def authorize_current_user_can_view_user(phase, user)
              valid = phase_user_view_user?(phase, current_user, user)
              access_denied(phase, "User #{msg_id user} does not have a common peer review team.")  unless valid
              debug_message('peer review', "authorized current user can peer review user #{msg_id user}.")  if debug?
            end

            # ################################### #
            # View ids
            # e.g. ownerable viewing a different ownerable such as a user or team.
            # ################################### #

            # Authorizations on view requests are based on the 'current user's teams unless can update the phase.
            # View ids are 'users' for peer review teams (e.g. users viewing users).
            # View ids are 'teams' for collaboration team users (e.g. teams viewing teams).
            def authorize_phase_view_ids(phase, ownerable, view_ids=params_view_ids, class_name=params_view_class_name)
              view_ids.each do |view_id|
                case class_name
                when user_class.name
                  authorize_phase_view_user_id(phase, view_id)
                when team_class.name
                  authorize_phase_view_team_id(phase, view_id)
                else
                  access_denied(phase, "Invalid view action class [#{class_name}].")
                end
              end
            end

            def authorize_phase_view_user_id(phase, user_id)
              user = user_class.find_by(id: user_id)
              access_denied(phase, "View user #{msg_id user_id}] not found.")  if user.blank?
              authorize_user_is_a_phase_user(phase, user)
              if can_update_phase?
                debug_message('view user', "authorized view user #{msg_id user} since phase updater.")  if debug?
              else
                if is_same_record?(current_user, user)
                  debug_message('view user', "authorized current_user #{msg_id current_user} is viewing themself #{msg_id user}.")  if debug?
                else
                  authorize_current_user_can_view_user(phase, user)
                  debug_message('view user', "authorized current_user #{msg_id current_user} can peer review user #{msg_id user}.")  if debug?
                end
              end
            end

            def authorize_phase_view_team_id(phase, team_id)
              team = team_class.find_by(id: team_id)
              access_denied(phase, "View team #{msg_id team_id}] not found.")   if team.blank?
              authorize_team_is_a_phase_team(phase, team)
              if can_update_phase?
                debug_message('view team', "authorized view team #{msg_id team} since phase updater.")  if debug?
              else
                authorize_current_user_on_or_can_view_team(phase, team)
                debug_message('view team', "authorized current_user #{msg_id current_user} can peer review team #{msg_id team}.")  if debug?
              end
            end

            # ###
            # ### Team Helpers.
            # ###

            def phase_user_on_team?(phase, user, team)
              assignment = get_phase_assignment(phase)
              team_class.users_on_teams?(phase, user, team) || team_class.users_on_teams?(assignment, user, team)
            end

            def phase_user_view_team?(phase, user, team)
              assignment = get_phase_assignment(phase)
              team_class.users_view_teams?(phase, user, team) || team_class.users_view_teams?(assignment, user, team)
            end

            def phase_user_view_user?(phase, user, view_user)
              assignment = get_phase_assignment(phase)
              team_class.users_view_users?(phase, user, view_user) || team_class.users_view_users?(assignment, user, view_user)
            end

            def phase_user_can_peer_review_users?(phase, user)
              return false unless phase_peer_review?(phase)
              assignment = get_phase_assignment(phase)
              team_class.users_teams(phase, user).exists? || team_class.users_teams(assignment, user).exists? ||
              team_class.can_view_users?(phase, user)     || team_class.can_view_users?(assignment, user)
            end

            def phase_user_can_peer_review_teams?(phase, user)
              # return false unless phase_peer_review?(phase)
              return false unless phase_collaboration?(phase)
              assignment = get_phase_assignment(phase)
              team_class.can_view_teams?(phase, user)  || team_class.can_view_teams?(assignment, user)
            end

            # ###
            # ### Helpers.
            # ###

            def access_denied(*args)
              options = args.extract_options!
              record  = args.shift
              message = args.shift
              if message.blank? && record.instance_of?(String)
                message = record
                record  = nil
              end
              message = 'AuthorizePhases: ' + message
              super(record, message, options)
            end

            def get_phase_assignment(phase); @_phase_assignment ||= phase.thinkspace_casespace_assignment; end

            def phase_peer_review?(phase);   @_phase_is_peer_review   ||= phase.peer_review?; end
            def phase_collaboration?(phase); @_phase_is_collaboration ||= phase.collaboration?; end

            def can_read_all?; can_update_phase? && is_read?; end

            def phase_is_team_ownerable?(phase); phase.team_ownerable?; end

            def can_update_phase?; @can_update_phase; end

            def record_carry_forward_scope_hash
              names       = params[:names]
              user_ids    = params[:view_ids]
              phase_id    = params[:phase_id] # This is the phase requesting it, so need to expand to any phase in the assignment.
              phase       = authable_record_class.find(phase_id)
              assignment  = get_phase_assignment(phase)
              phase_ids   = assignment.thinkspace_casespace_phases.pluck(:id)
              {phase_id: phase_ids, name: names}
            end

            def set_ownerable_abilities_for_user(user)
              is_current_user = is_same_record?(current_user, user)
              set_ownerable_ability(create: is_current_user, update: is_current_user, destroy: is_current_user)
            end

        end
      end
    end
  end
end
