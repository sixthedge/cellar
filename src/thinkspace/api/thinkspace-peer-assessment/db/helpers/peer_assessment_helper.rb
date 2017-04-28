def create_peer_assessment_assessment(*args)
  options    = args.extract_options!
  assessment = @seed.new_model(:peer_assessment, :assessment, options)
  @seed.create_error(assessment) unless assessment.save
  assessment
end