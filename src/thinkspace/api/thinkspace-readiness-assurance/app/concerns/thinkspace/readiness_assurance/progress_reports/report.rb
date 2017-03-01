module Thinkspace; module ReadinessAssurance; module ProgressReports
class Report
  attr_reader :assessment

  def initialize(assessment)
    @assessment = assessment
  end

  def process
    @assessment.ifat? ? Ifat.new(@assessment).process : Standard.new(@assessment).process
  end


end; end; end; end