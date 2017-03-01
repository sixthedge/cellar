require File.expand_path('../ember_helper', __FILE__)

describe 'ember.rb error' do

  it 'E01: namespace error' do 
    e = assert_raises(RuntimeError) {before_ember_common(file_ext: 'error/01_*')}
    assert_match(/duplicate namespace name/i, e.to_s)
  end

  it 'E02: namespace alias error' do 
    e = assert_raises(RuntimeError) {before_ember_common(file_ext: 'error/02_*')}
    assert_match(/duplicate namespace alias/i, e.to_s)
  end

end
