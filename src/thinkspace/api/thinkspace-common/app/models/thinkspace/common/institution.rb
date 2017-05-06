module Thinkspace
  module Common
    class Institution < ActiveRecord::Base
      totem_associations

      validates :title, presence: true, uniqueness: { case_sensitive: false }

    end
  end
end
