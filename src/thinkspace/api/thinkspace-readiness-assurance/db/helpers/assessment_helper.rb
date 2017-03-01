def create_readiness_assurance_assessment(*args)
  options = args.extract_options!
  list    = @seed.new_model(:readiness_assurance, :assessment, options)
  @seed.create_error(list)  unless list.save
  list
end

def create_readiness_assurance_response(*args)
  options  = args.extract_options!
  response = @seed.new_model(:readiness_assurance, :response, options)
  @seed.create_error(response)  unless response.save
  response
end
