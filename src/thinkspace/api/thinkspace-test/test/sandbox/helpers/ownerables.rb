module Test::Sandbox::Helpers::Ownerables
extend ActiveSupport::Concern
included do

  def read_1;   @_read_1   ||= get_user(:read_1); end
  def read_2;   @_read_2   ||= get_user(:read_2); end
  def read_3;   @_read_3   ||= get_user(:read_3); end
  def read_4;   @_read_4   ||= get_user(:read_4); end
  def read_5;   @_read_5   ||= get_user(:read_5); end
  def read_6;   @_read_6   ||= get_user(:read_6); end
  def update_1; @_update_1 ||= get_user(:update_1); end
  def owner_1;  @_owner_1  ||= get_user(:owner_1); end

end; end
