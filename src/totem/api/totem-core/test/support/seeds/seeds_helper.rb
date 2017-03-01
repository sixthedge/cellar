require File.expand_path('../../support_helper', __FILE__)

def register_seed_engines
  clear_engine_instances
  file = nil
  register_engine(file: file, path: 'test/framework/core',      platform_path: 'test/framework')
  register_engine(file: file, path: 'test/framework/seed_one',  platform_path: 'test/framework')
  register_engine(file: file, path: 'test/framework/seed_two',  platform_path: 'test/framework')
  register_engine(file: file, path: 'test/framework/seed_zero', platform_path: 'test/framework')
  register_engine(file: file)
  register_engine(file: file, path: 'test/platform/seed_zero')
  register_engine(file: file, path: 'test/platform/seed_one')
  register_engine(file: file, path: 'test/platform/seed_two')
end

def seed_loader
  Totem::Core::Support::SeedLoader
end