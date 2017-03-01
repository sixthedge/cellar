module Thinkspace
  module Common
    class Configuration < ActiveRecord::Base
      totem_associations
      before_save :set_settings_will_change

      private

      # This is REQUIRED until Rails 4.2
      # => ActiveRecord does not flag JSON/Hstore columns as dirty (subsequently avoiding the update) in all instances.
      # => This forces a rewrite of the settings column everytime.
      def set_settings_will_change
        self.settings_will_change!
      end
      
    end
  end
end