module Test; module Sandbox; module Helpers; module All
extend ActiveSupport::Concern
included do

  include Casespace::All
  include Sandbox::Helpers::Assert
  include Sandbox::Helpers::Cache
  include Sandbox::Helpers::Models
  include Sandbox::Helpers::Ownerables

  def self.get_tests
    @tests
  end

  def self.add_test(test)
    @tests ||= Array.new
    @tests.push(test)
  end

  def time_now; @time_now ||= Time.now.utc; end

end; end; end; end; end
