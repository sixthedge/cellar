module Thinkspace; module Common; module Concerns; module Filters; module Admin;
  module Spaces

    def scope_by_states(states)
      users = @scope.where('thinkspace_common_space_users.state IN (?)', states)
      ids   = users.distinct(:id).pluck(:id)
      add_result('id', ids)
    end

    def scope_by_roles(roles)
      users = @scope.where('thinkspace_common_space_users.role IN (?)', roles)
      ids   = users.distinct(:id).pluck(:id)
      add_result('id', ids)
    end

  end
end; end; end; end; end