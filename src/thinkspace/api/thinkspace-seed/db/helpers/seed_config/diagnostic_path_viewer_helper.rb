#########################################################################################
# ###
# ### Diagnostic Path Viewer Phase Componentable.
# ###
def create_casespace_phase_componentable_diagnostic_path_viewer(phase, section, common_component, config)
  title      = config[:phase]
  path_phase = title.blank? ? phase : find_casespace_phase(title: title)
  @seed.error "Diagnostic path viewer phase #{title.inspect} section #{section.inspect} not found."  if path_phase.blank?
  hash      = config[:ownerable]
  ownerable = find_casespace_user(hash)
  @seed.error "Diagnostic path viewer ownerable #{hash.inspect} section #{section.inspect} not found."  if ownerable.blank?
  path_section   = config[:section]
  path_component = @seed.get_association(path_phase, :casespace, :phase_components).find_by(section: path_section)
  @seed.error "Diagnostic path viewer phase component #{hash.inspect} for the path section #{path_section.inspect} not found."  if path_component.blank?
  path = path_component.componentable
  @seed.error "Diagnostic path viewer path for phase #{path_phase.title.inspect} path section #{path_section.inspect} not found."  if path.blank?
  create_diagnostic_path_viewer_viewer authable: phase, ownerable: ownerable, path: path, user: ownerable
end
