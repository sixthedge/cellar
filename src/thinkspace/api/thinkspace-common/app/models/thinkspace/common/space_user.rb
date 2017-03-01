module Thinkspace
  module Common
    class SpaceUser < ActiveRecord::Base
      totem_associations

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      # ###
      # ### Notifications.
      # ###

      def notify_added_to_space(inviter)
        Thinkspace::Common::NotificationMailer.added_to_space(self, inviter).deliver_now
      end

      def notify_invited_to_space(inviter)
        Thinkspace::Common::NotificationMailer.invited_to_space(self, inviter).deliver_now
      end

    end
  end
end
