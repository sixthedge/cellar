# db reset:
#  rake db:drop db:create totem:db:reset[staging] CONFIG=all AI=true

# seeds only (faster when testing seeds multiple times):
#  Uncomment '@seed.reset_tables'.
#  rake totem:db:seed:engine[thinkspace_casespace,staging] CONFIG=all AI=true RESET=true
# @seed.reset_tables

casespace_seed_configs_process
