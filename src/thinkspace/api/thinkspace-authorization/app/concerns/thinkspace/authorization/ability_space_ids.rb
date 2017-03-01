module Thinkspace; module Authorization; module AbilitySpaceIds

  attr_reader :read_space_ids, :admin_space_ids

  def admin?; admin_space_ids.present?; end
  def read_space_users_states; ['active']; end

  private

  def set_ability_space_ids
    read_only_ids = Array.new
    update_ids    = Array.new
    owner_ids     = Array.new
    get_user_space_roles.each do |usr|
      roles    = usr.user_roles
      space_id = usr.s_id
      next if roles.blank? || space_id.blank?
      case
      when roles.include?('read')    then read_only_ids.push(space_id)
      when roles.include?('update')  then update_ids.push(space_id)
      when roles.include?('owner')   then owner_ids.push(space_id)
      end
    end
    # 'admin' means can update or is the owner.
    @admin_space_ids = (update_ids + owner_ids).uniq
    @read_space_ids  = (read_only_ids + admin_space_ids).uniq
  end

  def get_user_space_roles
    Thinkspace::Common::Space.
    joins(:thinkspace_common_space_users).
    # If filter the space users by state (e.g. state: :active) then don't need the array_agg for state.
    where(thinkspace_common_space_users: {user_id: user.id, state: read_space_users_states}).
    select('thinkspace_common_spaces.id as s_id').
    select('array_agg(thinkspace_common_space_users.role)  as user_roles').
    group(:s_id).
    order(:id)
  end


end; end; end

