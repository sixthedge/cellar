module Thinkspace
  module ReadinessAssurance
    class Status < ActiveRecord::Base
      totem_associations
      has_paper_trail
    end
  end
end
