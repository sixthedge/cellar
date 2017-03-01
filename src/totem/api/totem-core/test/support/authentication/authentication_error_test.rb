require File.expand_path('../authentication_helper', __FILE__)

describe 'authentication.rb errors' do

  before do 
    before_authentication_common(file_ext: 'error/01_*')
  end

  it 'E01: blank oauth provider site' do 
    set_secrets_oauth_providers(file: __FILE__, file_ext: 'error/secrets/01_')
    e = assert_raises(RuntimeError) {set_oauth_providers}
    assert_match(/not have a site defined/i, e.to_s)
  end

end
