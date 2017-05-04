# db reset:
#  rails db:drop db:create totem:db:reset[pe] CONFIG=all AI=true

# seeds only (faster when testing seeds multiple times):
#  Uncomment '@seed.reset_tables'.
#  rails totem:db:seed:engine[thinkspace_casespace,pe] CONFIG=all AI=true RESET=true
@seed.reset_tables

casespace_seed_configs_process
