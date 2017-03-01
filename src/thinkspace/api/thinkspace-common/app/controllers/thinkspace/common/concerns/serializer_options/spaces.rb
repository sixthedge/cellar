require 'pp'

module Thinkspace; module Common; module Concerns; module SerializerOptions; module Spaces

  def index(serializer_options)
    serializer_options.include_module_ability module: Spaces
    common_cache_serializer_options(serializer_options)
    common_serializer_options(serializer_options)
  end

  def show(serializer_options)
    common_serializer_options(serializer_options)
  end

  # ###
  # ### Helpers.
  # ###

  def common_serializer_options(serializer_options)
    serializer_options.include_metadata
    serializer_options.ability_actions  :update, scope: :root

    serializer_options.remove_all_except(
      :thinkspace_casespace_assignments,
      :thinkspace_common_owners,
      :thinkspace_common_space_types,
      # :thinkspace_team_team_sets,
      scope: :root
    )

    serializer_options.scope_association(:thinkspace_casespace_assignments, 
      scope_assignment_association: [:record, :current_ability, :current_user]
    )

    serializer_options.remove_all scope: :thinkspace_common_user

    serializer_options.include_association :thinkspace_common_owners, scope: :root
    serializer_options.include_association :thinkspace_common_space_types, scope: :root

    serializer_options.authorize_action :read_space_owners, :thinkspace_common_owners,      scope: :root
    serializer_options.authorize_action :read_space_owners, :thinkspace_common_space_users, scope: :root
  end

  def common_cache_serializer_options(serializer_options)
    serializer_options.cache ownerable: serializer_options.current_user, model_query_key: true
    serializer_options.cache_query_key name: :spaces, column: :updated_at
    serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
    serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
    serializer_options.cache_query_key name: :owners, maximum: :thinkspace_common_owners, table: :thinkspace_common_users
    # TODO: Is there a way to add this?
    # serializer_options.cache_query_key(name: :release_at,  maximum: :thinkspace_casespace_assignments,
    #   where:  ['thinkspace_casespace_assignments.release_at < ?', Time.now],
    #   column: :release_at
    # )
  end

  # ###
  # ### Class Methods.
  # ###

  def self.space_updater?(ownerable)
    true # Default to true for now.
    # return false unless ownerable.is_a?(Thinkspace::Common::User)
    # Thinkspace::Common::SpaceUser.where(user_id: ownerable.id, role: [:owner, :update]).exists? # Only TA/instructors
  end

  # index
  def self.ability_spaces(controller, ownerable)
    hash          = Hash.new
    update        = space_updater?(ownerable)
    hash[:update] = update
    hash[:create] = update
    hash
  end

end; end; end; end; end
