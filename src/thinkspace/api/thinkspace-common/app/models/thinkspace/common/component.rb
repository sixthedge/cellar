module Thinkspace
  module Common
    class Component < ActiveRecord::Base
      totem_associations
      validates :title, presence: true, uniqueness: true
    end
  end
end
