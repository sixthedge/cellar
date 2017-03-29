module Test; module ReadinessAssurance; module Helpers; module All
extend ActiveSupport::Concern
included do

  include Casespace::All
  include PhaseActions::Helpers::Actions
  include PhaseActions::Helpers::Ownerables
  include PhaseActions::Helpers::Assert
  include ReadinessAssurance::Helpers::Models
  include ReadinessAssurance::Helpers::Response
  include ReadinessAssurance::Helpers::Answers
  include ReadinessAssurance::Helpers::Ownerables
  include ReadinessAssurance::Helpers::Params
  include ReadinessAssurance::Helpers::Assert

  def self.get_tests
    @tests
  end

  def self.add_test(test)
    @tests ||= Array.new
    @tests.push(test)
  end

  def time_now; @time_now ||= Time.now.utc; end

end; end; end; end; end
