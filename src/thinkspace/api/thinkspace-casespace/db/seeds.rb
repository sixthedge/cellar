# See 'db/test_data/README.md' for documentation on loading test data.
@seed = ::Totem::Settings.seed.loader

@seed.require_platform_helpers(:thinkspace)
set_common_seed_loader_namespaces

test_data_seed_name = @seed.test_data_seed_name
test_files          = nil

unless Rails.env.production?
  unless test_data_seed_name == 'none'
    test_files = File.join(@seed.db_data_dir(:casespace), test_data_seed_name, '_seed.rb')
    @seed.raise_error "Seed file #{test_files.inspect} does not exist.  No test seed data loaded!"  unless File.exists?(test_files)
  end
end

@seed.load seeds: nil, test_data: test_files
