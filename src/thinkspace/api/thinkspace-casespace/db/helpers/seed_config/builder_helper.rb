#########################################################################################
# ###
# ### Builder
# ###
def create_builder_templates(configs)
  # Currently create a template for all assignment and phases.
  # Could add a flag in the config to determine whether to add to the case manager templates.
  spaces      = @seed.model_class(:common, :space).all
  assignments = @seed.model_class(:casespace, :assignment).all
  phases      = @seed.model_class(:casespace, :phase).all
  spaces.each { |record| create_builder_template(record) }
  assignments.each { |record| create_builder_template(record) }
  phases.each { |record| create_builder_template(record) }
end

def create_builder_template(record)
  title = (record.title || 'no_title').humanize
  options = {
    templateable: record,
    title:        title,
    description:  'Description ' + title,
  }
  template = @seed.new_model(:builder, :template, options)
  @seed.create_error(template)  unless template.save
  template
end
