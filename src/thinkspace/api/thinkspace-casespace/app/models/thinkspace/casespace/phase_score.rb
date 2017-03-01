module Thinkspace
  module Casespace
    class PhaseScore < ActiveRecord::Base
      totem_associations
      has_paper_trail
      validates_presence_of :thinkspace_casespace_phase_state
    end
  end
end
