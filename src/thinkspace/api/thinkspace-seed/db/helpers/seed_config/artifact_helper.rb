#########################################################################################
# ###
# ### Artifact Phase Componentable.
# ###
def create_casespace_phase_componentable_artifact(phase, section, common_component, config)
  instructions = config[:instructions]
  create_artifact_bucket(authable: phase, instructions: instructions)
end
