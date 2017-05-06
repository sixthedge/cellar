module Thinkspace
  module Common
    class InstitutionUser < ActiveRecord::Base
      totem_associations
      has_paper_trail

      validates_presence_of :thinkspace_common_institution
      validates_presence_of :thinkspace_common_user

    end
  end
end
