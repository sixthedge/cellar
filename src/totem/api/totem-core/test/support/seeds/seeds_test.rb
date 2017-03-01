require File.expand_path('../seeds_helper', __FILE__)

describe 'seeds.rb' do

  before do 
    set_environment
    @seed = @env.seed
  end

  it 'should be an instance of seed_loader' do
    assert_kind_of seed_loader, @seed.loader
  end

end

