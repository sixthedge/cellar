module Thinkspace; module Authorization; module AbilityInstitutionIds

  attr_reader :admin_institution_ids

  def institution_states;       ['active']; end
  def institution_users_states; ['active']; end
  def institution_iadmin_role;  ['iadmin']; end

  def iadmin?; admin_institution_ids.present?; end

  private

    def set_ability_institution_ids
    @admin_institution_ids = user
      .thinkspace_common_institutions
      .where(state: institution_states)
      .where(thinkspace_common_institution_users: {state: institution_users_states, role: institution_iadmin_role})
      .pluck(:id)
  end

end; end; end
