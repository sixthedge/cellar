module Test::Casespace::Utility
  extend ActiveSupport::Concern
  included do

    def timestamp; @timestamp ||= Time.now; end

    def get_let_value(name);       (self.respond_to?(name.to_sym) && self.send(name)) || nil; end
    def get_let_value_array(name); [get_let_value(name)].flatten.compact; end

  end # included
end
