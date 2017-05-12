# To populate test db with this seed, run:
#   rake totem:db:reset RAILS_ENV='test'
#   rake totem:db:reset RAILS_ENV='test' CONFIG=clone AI=true
# See README.md for examples.

@seed.require_platform_helpers(:thinkspace)
seed_configs_process

# @seed.print_tables
