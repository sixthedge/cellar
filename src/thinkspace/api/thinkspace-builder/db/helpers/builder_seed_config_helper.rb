#########################################################################################
# ###
# ### Process Configs.
# ###
def builder_seed_configs_process
  builder_seed_config_process_templates
end

def builder_seed_config_process_templates
  @seed.message "++Adding builder templates. (all spaces, assignments and phases)"
  create_builder_templates
end

