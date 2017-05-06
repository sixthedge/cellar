module Thinkspace; module Authorization
class ThinkspaceCasespace < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  protected

  def read_assignment;         {space_id: read_space_ids}.merge(read_states); end
  def read_phase;              {thinkspace_casespace_assignment: read_assignment}.merge(read_states);  end
  def read_phase_association;  {thinkspace_casespace_phase: read_phase};  end
  def read_phase_score;        {thinkspace_casespace_phase_state: read_phase_association};  end

  def admin_assignment;        get_admin_assignment_space_ability.merge(admin_states); end
  def admin_phase;             {thinkspace_casespace_assignment: admin_assignment}.merge(admin_states); end
  def admin_phase_association; {thinkspace_casespace_phase: admin_phase}; end
  def admin_phase_score;       {thinkspace_casespace_phase_state: admin_phase_association}; end


  def read_states;  {state: ['active']}; end
  def admin_states; {state: ['active', 'inactive', 'archived']}; end

  def get_admin_assignment_space_ability
    @_admin_assignment_space_ability ||= begin
      case
      when iadmin?     then {thinkspace_common_space: {institution_id: admin_institution_ids}}
      when admin?      then {space_id: admin_space_ids}
      else Hash.new
      end
    end
  end

  private

  def domain
    can [:read], Thinkspace::Casespace::PhaseTemplate
    can [:read], Thinkspace::Casespace::PhaseComponent
  end

  def assignments
    assignment = Thinkspace::Casespace::Assignment
    can [:read, :phase_states], assignment, read_assignment
    return unless admin_ability?
    can [:read, :phase_states], assignment, admin_assignment
    can [:create], assignment
    can [:templates, :clone, :delete, :load, :update, :view, :roster, :phase_order, :phase_componentables, :activate, :inactivate, :archive], assignment, admin_assignment
    can [:gradebook, :manage_resources, :report], assignment, admin_assignment
  end

  def assignment_types
    assignment_type = Thinkspace::Casespace::AssignmentType
    can [:read], assignment_type
  end

  def phases
    phase       = Thinkspace::Casespace::Phase
    phase_state = Thinkspace::Casespace::PhaseState
    phase_score = Thinkspace::Casespace::PhaseScore
    can [:read, :load, :submit], phase, read_phase
    can [:read], phase_state, read_phase_association
    can [:read], phase_score, read_phase_score
    return unless admin_ability?
    can [:read, :load, :submit, :report], phase, admin_phase
    can [:templates, :clone, :update, :bulk_reset_date, :destroy, :componentables, :activate, :archive, :inactivate, :delete_ownerable_data], phase, admin_phase
    can [:create], [phase_state, phase_score]
    can [:update, :roster_update, :gradebook], phase_state, admin_phase_association
    can [:update, :gradebook], phase_score, admin_phase_score
  end

  # ###
  # ### Related Engines.
  # ###

  def resource
    return unless ns_exists?('Thinkspace::Resource')
    can [:crud], Thinkspace::Resource::File
    can [:crud], Thinkspace::Resource::Link
    can [:crud], Thinkspace::Resource::Tag
    can [:read], Thinkspace::Resource::FileTag
    can [:read], Thinkspace::Resource::LinkTag
  end

end; end; end
