def create_peer_assessment_assessment(*args)
  options    = args.extract_options!
  assessment = @seed.new_model(:peer_assessment, :assessment, options)
  @seed.create_error(assessment) unless assessment.save
  assessment
end

def create_peer_assessment_overview(*args)
  options  = args.extract_options!
  overview = @seed.new_model(:peer_assessment, :overview, options)
  @seed.create_error(overview) unless overview.save
  overview
end