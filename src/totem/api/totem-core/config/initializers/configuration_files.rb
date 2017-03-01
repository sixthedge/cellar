
# Platform configuration file extension; use '*' to include multiple files (e.g. '*.config.yml') otherwise only the file specified is used
::Totem::Settings.option.configuration_file_extension = '*.config.yml'

# Directories to search for platform configuration files (files in directory matching the configuration_file_extension)
# Absolute paths so typically should start with: Rails.root.join('match-pattern')
# See Ruby Dir#glob for directory match-pattern format
::Totem::Settings.option.configuration_file_directory_search = Rails.root.join('config/totem')

# Filename of the database association yml file.
# It must be in the [rails|engine].root/db directory.
::Totem::Settings.option.db_associations_filename = 'associations.yml'
