module Thinkspace; module Casespace; module Concerns; module SerializerOptions; module Phases

  def show(serializer_options)
    serializer_options.remove_all_except :thinkspace_casespace_assignment
  end

  def select(serializer_options); show(serializer_options); end

  def submit(serializer_options)  # serializing phase_states (not a phase)
    serializer_options.remove_association :ownerable
    serializer_options.remove_association :thinkspace_common_user
  end

  def update(serializer_options); show(serializer_options); end

  def load(serializer_options)
    serializer_options.cache
    common_cache_serializer_options(serializer_options)

    serializer_options.remove_association  :thinkspace_casespace_phase_states
    serializer_options.remove_association  :componentable
    serializer_options.remove_association  :thinkspace_casespace_phases,           scope: :thinkspace_casespace_phase_template
    serializer_options.remove_association  :thinkspace_casespace_phase_components, scope: :thinkspace_casespace_phase_template
    serializer_options.remove_association  :thinkspace_team_teams
    serializer_options.remove_association  :thinkspace_team_team_set_teamables
    serializer_options.remove_association  :ownerable
    serializer_options.remove_association  :thinkspace_common_user, scope: :thinkspace_casespace_phase_scores
    serializer_options.remove_association  :thinkspace_common_user, scope: :thinkspace_casespace_phase_states

    serializer_options.blank_association   :thinkspace_casespace_phase_scores

    serializer_options.include_association :thinkspace_common_configuration
    serializer_options.include_association :thinkspace_casespace_phase_template
    serializer_options.include_association :thinkspace_common_component
    serializer_options.include_association :thinkspace_casespace_phase_components

    serializer_options.include_association :thinkspace_resource_files
    serializer_options.include_association :thinkspace_resource_links
    serializer_options.include_association :thinkspace_resource_tags

    set_abilities(serializer_options)
  end

  # ###
  # ### Helpers.
  # ###

  # Only valid for one phase e.g. actions load, show.
  # A select action with multiple ids will return the combined abilities - not what is wanted.
  def set_abilities(serializer_options)
    serializer_options.include_ability(
        scope:             :root,
        update:            serializer_options.authable_ability[:update],
        manage_resources:  serializer_options.authable_ability[:update],
        peer_review_users: serializer_options.authable_ability[:peer_review_users],
        peer_review_teams: serializer_options.authable_ability[:peer_review_teams],
        modify_assignment: serializer_options.authable_ability[:modify_assignment],
        modify_phase:      serializer_options.authable_ability[:modify_phase],
        read_assignment:   serializer_options.authable_ability[:read_assignment],
        read_phase:        serializer_options.authable_ability[:read_phase]
      )
  end

  def common_cache_serializer_options(serializer_options)
    serializer_options.cache_query_key name: :phase
    serializer_options.cache_query_key name: :phase_template,   pluck: :thinkspace_casespace_phase_template
    serializer_options.cache_query_key name: :configuration,    pluck: :thinkspace_common_configuration
    serializer_options.cache_query_key name: :phase_components, maximum: :thinkspace_casespace_phase_components
    serializer_options.cache_query_key name: :team_category_id, column: :team_category_id
    serializer_options.cache_query_key name: :resource_tags,    maximum: :thinkspace_resource_tags
    serializer_options.cache_query_key name: :resource_files,   maximum: :thinkspace_resource_files
    serializer_options.cache_query_key name: :resource_links,   maximum: :thinkspace_resource_links
    serializer_options.cache_query_key name: :team_set_id, maximum: :thinkspace_team_team_set_teamables
  end


  # ###
  # ### Class methods
  # ###

  # phase_component_abilities
  def self.ability_builder_abilities(controller, phase, ownerable)
    abilities                     = phase.get_builder_abilities
    abilities[:update]            = controller.current_ability.can?(:update, phase)
    abilities[:manage_resources]  = controller.current_ability.can?(:update, phase)
    abilities[:peer_review_users] = controller.current_ability.can?(:peer_review_users, phase)
    abilities[:peer_review_teams] = controller.current_ability.can?(:peer_review_teams, phase)
    abilities
  end


end; end; end; end; end
