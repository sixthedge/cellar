module Thinkspace
  module Common
    module DeleteOwnerableDataHelper

      public

      def delete_all_ownerable_data!
        delete_ownerable_data_scope_all
      end

      def delete_ownerable_data(ownerables)
        delete_ownerable_data_scope_by_ownerables(ownerables)
      end

      private

      # Using 'destroy_all' so any destroy callbacks will be triggered and
      # also create a paper trail 'versions' copy of the destroyed record.

      def delete_ownerable_data_scope_all
        self.transaction do
          [ownerable_data_associations].flatten.compact.each do |association|
            get_delete_ownerable_data_association_scope(association).destroy_all
          end
        end
      end

      def delete_ownerable_data_scope_by_ownerables(ownerables)
        self.transaction do
          ownerables = get_delete_ownerable_data_ownerables(ownerables)
          [ownerable_data_associations].flatten.compact.each do |association|
            scope = get_delete_ownerable_data_association_scope(association)
            ownerables.each do |ownerable|
              scope.where(ownerable: ownerable).destroy_all
            end
          end
        end
      end

      def get_delete_ownerable_data_association_scope(association)
        raise_delete_ownerable_data_exception "#{self.class.name.inspect} does not have association #{association.inspect}."  unless self.respond_to?(association)
        self.send(association).all
      end

      def get_delete_ownerable_data_ownerables(ownerables)
        ownerables = [ownerables].flatten.compact
        raise_delete_ownerable_data_exception "Ownerables are blank."  if ownerables.blank?
        ownerables
      end

      # The class must define this method after including this module.
      def ownerable_data_associations
        raise_delete_ownerable_data_exception "#{self.class.name.inspect} did not define a 'ownerable_data_associations' method."
      end

      def raise_delete_ownerable_data_exception(message)
        raise DeleteOwnerableDataError, message
      end

      class DeleteOwnerableDataError < StandardError; end

    end
  end
end
