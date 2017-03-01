module Thinkspace
  module ReadinessAssurance
    class Chat < ActiveRecord::Base
      totem_associations
      has_paper_trail
    end
  end
end
