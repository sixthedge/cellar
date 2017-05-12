module Test; module SerializerAsm10; module Helpers; module All
extend ActiveSupport::Concern
included do

  include Casespace::All
  include SerializerAsm10::Helpers::Assert
  include SerializerAsm10::Helpers::Models
  include SerializerAsm10::Helpers::Ownerables

  def self.get_tests
    @tests
  end

  def self.add_test(test)
    @tests ||= Array.new
    @tests.push(test)
  end

  def time_now; @time_now ||= Time.now.utc; end

end; end; end; end; end
