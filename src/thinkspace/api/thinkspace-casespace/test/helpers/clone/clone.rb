module Test::Clone::Clone
  extend ActiveSupport::Concern
  included do

    def clone_record(options={})
      options[:dictionary] = record.get_clone_dictionary
      options.reverse_merge!(ownerable: ownerable) if ownerable.present? && !options.has_key?(:ownerable)
      options.reverse_merge!(user: user)           if user.present? && !options.has_key?(:user)
      cloned_record = record.cyclone(options)
      print_options_dictionary_ids(options)  if self.respond_to?(:print_ids) && self.send(:print_ids) == true
      [cloned_record, options]
    end

    def get_dictionary(options={}); options[:dictionary]; end
    def is_full_clone?(options={}); options[:is_full_clone] == true; end

  end # included
end
