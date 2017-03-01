if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    # add_filter 'test'
    command_name 'Mintest'
  end
end

ENV["RAILS_ENV"] ||= "test"

# Path to Rails.root/config/environment.rb (note: Rails.root not yet initialized).
require ENV['MAIN_APP_CONFIG_ENV']

require 'rails/test_help'
require 'minitest/spec'
require 'minitest/mock'

def totem_unit_tests?
  ENV['UNIT_TESTS'] == 'true'
end

puts "\n"
puts "[env] Running in [#{Rails.env}] environment.  Unit tests: #{totem_unit_tests?.inspect}"
puts "\n"

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!  unless totem_unit_tests?

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # class << self
  #   remove_method :describe  # describe method added in Rails 3+ conflicts with spec DSL
  # end

  extend MiniTest::Spec::DSL

  # Register the type of describe description that should use an ActiveSupport::TestCase.
  # activesupport-4.0.3/lib/active_support/test_case.rb inherits from MiniTest.
  # e.g. ActiveSupport::TestCase < ::MiniTest::Unit::TestCase
  # ActiveSupport::TestCase adds extra functionality like better 'test' logging
  # and addition matchers.
  register_spec_type(self) do |desc|
    if desc.is_a?(Class)
      desc < ActiveRecord::Base
    elsif desc.is_a?(String)  # when a string, use an ActiveSupport::TestCase
      true
    else
      false
    end
  end

  # Add more helper methods to be used by all tests here...
end
