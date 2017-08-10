module Thinkspace; module ReadinessAssurance; module Concerns; module SerializerOptions; module Assessments

  def show(serializer_options)
    serializer_options.remove_all_except   :thinkspace_readiness_assurance_responses, :thinkspace_readiness_assurance_chat
    serializer_options.blank_association   :thinkspace_readiness_assurance_responses
    serializer_options.blank_association   :thinkspace_readiness_assurance_chat
    # add_response_view_abilities(serializer_options)
    serializer_options.include_ability(
      update: serializer_options.current_ability.can?(:update, serializer_options.params_authable)
    )
  end

  def update(serializer_options)
    show(serializer_options)
  end

  def revert(serializer_options)
    show(serializer_options)
  end

  def sync(serializer_options); end

  def view(serializer_options)
    serializer_options.remove_all_except(
      :thinkspace_readiness_assurance_assessment,
      :thinkspace_readiness_assurance_responses,
      :thinkspace_readiness_assurance_response,
      :thinkspace_readiness_assurance_status,
      :thinkspace_readiness_assurance_chat,
    )
    serializer_options.include_association(
      :thinkspace_readiness_assurance_chat,
      :thinkspace_readiness_assurance_status,
      scope: :thinkspace_readiness_assurance_responses
    )
    serializer_options.include_association(
      :thinkspace_readiness_assurance_responses,
      scope_association: :params_ownerable
    )
    add_response_view_abilities(serializer_options)
  end

  def teams; end
  def trat_overview; end

  def add_response_view_abilities(serializer_options)
    serializer_options.include_ability(
      scope:  :thinkspace_readiness_assurance_responses,
      update: serializer_options.ownerable_ability[:update],
    )
  end

end; end; end; end; end
