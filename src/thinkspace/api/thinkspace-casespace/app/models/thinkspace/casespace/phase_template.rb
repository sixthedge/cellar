module Thinkspace
  module Casespace
    class PhaseTemplate < ActiveRecord::Base
      totem_associations

      # validates :title, presence: true#, uniqueness: true TODO: Are these needed?
      # validates :name,  presence: true#, uniqueness: true

    end
  end
end