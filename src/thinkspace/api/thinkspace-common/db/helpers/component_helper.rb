def create_common_component(*args)
  options   = args.extract_options!
  component = @seed.new_model(:common, :component, options)
  @seed.create_error(component)  unless component.save
  component
end

def find_common_component(*args)
  options = args.extract_options!
  @seed.model_class(:common, :component).find_by(options)
end
