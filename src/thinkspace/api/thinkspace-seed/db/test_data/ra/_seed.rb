# db reset:
#  rails db:drop db:create totem:db:reset[ra] CONFIG=all AI=true

# seeds only (faster when testing seeds multiple times):
#  Uncomment '@seed.reset_tables'.
#  rails totem:db:seed:engine[thinkspace_casespace,ra] CONFIG=all AI=true RESET=true
@seed.reset_tables

seed_configs_process
