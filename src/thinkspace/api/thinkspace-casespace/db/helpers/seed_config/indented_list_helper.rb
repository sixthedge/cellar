#########################################################################################
# ###
# ### Indented List Phase Componentable.
# ###
def create_casespace_phase_componentable_indented_list(phase, section, common_component, config)
  settings = (config || Hash.new).except(:phase, :expert).symbolize_keys
  expert   = false
  if config[:expert].present?
    expert = true
    title  = config[:phase]
    @seed.error "Indented list expert sections phase title is blank #{config.inspect}."  if title.blank?
    list_phase = find_casespace_phase(title: title)
    @seed.error "Indented list expert phase #{title.inspect} not found."  if list_phase.blank?
    list_class      = @seed.model_class(:indented_list, :list)
    phase_component = @seed.get_association(list_phase, :casespace, :phase_components).where(componentable_type: list_class.name).first
    @seed.error "Indented list expert phase #{title.inspect} does not have an indented list phase component."  if phase_component.blank?
    list               = phase_component.componentable
    settings[:list_id] = list.id
  end
  settings[:layout] ||= 'diagnostic_path'
  create_indented_list_list authable: phase, title: (phase.title || ''), expert: expert, settings: settings
end
