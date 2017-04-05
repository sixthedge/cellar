def add_casespace_phase_components
  casespace_get_assignments_created.each do |assignment|
    phases = @seed.get_association(assignment, :casespace, :phases).order(:id)
    phases.each do |phase|
      phase_template = @seed.get_association(phase, :casespace, :phase_template)
      @seed.error "Phase id #{phase.id} does not have a phase template."  if phase_template.blank?
      component_hash = get_ordered_phase_template_section_hash(phase_template)
      component_hash.each do |section, attrs|
        title            = attrs['title'] || ''
        common_component = find_common_component(title: title)
        @seed.error "Phase template #{phase_template.name.inspect} section #{section.inspect} common component #{title.inspect} not found."  if common_component.blank?
        componentable = get_casespace_phase_componentable(phase, section, common_component)
        create_casespace_phase_component(
          section:        section,
          phase:          phase,
          component:      common_component,
          componentable:  componentable,
        )
      end
    end
  end
  # Call any post phase component methods defined for a namespace.
  # e.g. "post_casespace_phase_componentables_observation_list" to group lists
  post_casespace_phase_componentables_methods.each do |method|
    self.send method
  end
end

def create_casespace_phase_component(*args)
  options         = args.extract_options!
  phase_component = @seed.new_model(:casespace, :phase_component, options)
  @seed.create_error(phase_component)  unless phase_component.save
  phase_component
end

def post_casespace_phase_componentables_methods
  methods = Array.new
  @seed.namespace_lookup.keys.sort.each do |key|
    method = "post_casespace_phase_componentables_#{key}".to_sym
    if self.respond_to?(method, true)
      methods.push method
    end
  end
  methods
end

#########################################################################################
# ###
# ### Componentable.
# ###

def get_casespace_phase_componentable(phase, section, common_component)
  ns, model = get_casespace_common_component_namespace_and_model(common_component)
  return phase if model == :phase
  # The value of the phase 'sections' depends on the type of component (typically a hash).
  # It can be any data type that allows the the component specific method to interpret it accordingly.
  # The config below is the phase's 'sections' value for this section.
  config = get_casespace_phase_template_section_configs[phase.id]
  config = (config || Hash.new)[section.to_sym] || Hash.new
  @seed.error "Phase #{phase.title.inspect} section #{section.inspect} namespace is blank.  Can not build phase componentable."  if ns.blank?
  method = "create_casespace_phase_componentable_#{ns}".to_sym
  unless self.respond_to?(method, true)
    @seed.message "Phase #{phase.title.inspect} section #{section.inspect} namespace #{ns.to_s.inspect} method #{method.to_s.inspect} not implemented."
    @seed.error "Can not build phase componentable."
  end
  self.send method, phase, section, common_component, config
end

def get_casespace_common_component_namespace_and_model(common_component)
  ns, model, other = common_component.value['path']
  comp_ns          = common_component.value['ns']
  ns               = comp_ns.present? ? comp_ns.to_sym : ns.to_s.split(':').last.to_sym
  model            = model.to_s.split(':').last.singularize.to_sym
  [ns, model]
end
