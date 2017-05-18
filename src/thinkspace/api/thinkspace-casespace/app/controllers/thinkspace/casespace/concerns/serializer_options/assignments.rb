module Thinkspace; module Casespace; module Concerns; module SerializerOptions; module Assignments

  def show(serializer_options);   common_serializer_options(serializer_options); end
  def select(serializer_options); common_serializer_options(serializer_options); end

  def roster(serializer_options); end

  def view(serializer_options)
    case serializer_options.sub_action
    when :gradebook_teams
      serializer_options.remove_all_except   :thinkspace_team_team_set_teamables
      serializer_options.include_association :thinkspace_team_team_set_teamables
      serializer_options.only_attributes     :id, :title, scope: :root
    when :gradebook_users
      serializer_options.include_association :thinkspace_common_users, authorize_action: :gradebook
      serializer_options.remove_association  :thinkspace_common_spaces, scope: :thinkspace_common_users
      serializer_options.ability_actions :update, scope: :root
    end
  end

  def phase_states(serializer_options)
    serializer_options.include_metadata
    common_member_cache_serializer_options(serializer_options)
    serializer_options.include_association :ownerable
    serializer_options.include_association :thinkspace_casespace_phase
    serializer_options.remove_association :thinkspace_common_user
    serializer_options.remove_all_except(
      :thinkspace_casespace_assignment,
      scope: :thinkspace_casespace_phase
    )
    serializer_options.remove_all(scope: :thinkspace_common_users)
  end

  # ###
  # ### Helpers.
  # ###

  def common_member_cache_serializer_options(serializer_options)
    # TODO: Fix this, get Totem::Core::Controllers::ApiRender::Cache::CacheError (Controller "Thinkspace::Casespace::Api::AssignmentsController": model does not respond to query_key method [query_key_for_timetables].):
    # => record_or_scope is [phase_state, phase_state...]
    # serializer_options.cache ownerable: serializer_options.params_ownerable,
    #   instance_var:     :assignment,
    #   query_key_method: :query_key_for_timetables,
    #   model_query_key:  true
    common_cache_serializer_options(serializer_options)
  end

  def common_serializer_options(serializer_options)
    serializer_options.include_metadata
    serializer_options.ability_actions :gradebook, :manage_resources, scope: :root
    serializer_options.remove_all_except(
      :thinkspace_common_space,
      :thinkspace_resource_files,
      :thinkspace_resource_tags,
      :thinkspace_resource_links,
      :thinkspace_casespace_assignment_type
    )
  end

  def common_cache_serializer_options(serializer_options)
    serializer_options.cache_query_key name: :assignment
    serializer_options.cache_query_key name: :phases, maximum: :thinkspace_casespace_phases, column: :updated_at
    serializer_options.cache_query_key(
      name:       :phase_states,
      scope:      [:thinkspace_casespace_phases, :scope_phase_states_by_ownerable],
      scope_args: [nil, serializer_options.cache_ownerable],
      table:      :thinkspace_casespace_phase_states,
    )
    serializer_options.cache_query_key(
      name:       :phase_state_ids,
      scope:      [:thinkspace_casespace_phases, :scope_phase_states_by_ownerable],
      scope_args: [nil, serializer_options.cache_ownerable],
      table:      :thinkspace_casespace_phase_states,
      method:     :pluck,
      column:     :id
    )
    serializer_options.cache_query_key(
      name:       :phase_scores,
      scope:      [:thinkspace_casespace_phases, :scope_phase_scores_by_ownerable],
      scope_args: [nil, serializer_options.cache_ownerable],
      table:      :thinkspace_casespace_phase_scores,
    )
  end

  # ###
  # ### Class Methods.
  # ###

  # show
  def self.ability_assignment(controller, record, ownerable)
    abilities                     = {}
    abilities[:gradebook]         = controller.current_ability.can?(:update, record)
    abilities[:manage_resources]  = controller.current_ability.can?(:update, record)
    abilities
  end

  def self.metadata_assignment(controller, record, ownerable); record.serializer_metadata(ownerable, controller.get_serializer_options); end

end; end; end; end; end
