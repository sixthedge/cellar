module Thinkspace
  module Resource
    class Link < ActiveRecord::Base

      totem_associations

      def get_updateable; self.class.find(self.id); end  # return a record that can be updated (e.g. not through readonly association)

    end
  end
end