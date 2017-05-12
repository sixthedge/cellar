#########################################################################################
# ###
# ### Diagnostic Path Phase Componentable.
# ###
def create_casespace_phase_componentable_diagnostic_path(phase, section, common_component, config)
  create_diagnostic_path_path authable: phase, title: "#{section} - #{phase.title}"
end
