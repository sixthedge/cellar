module Test::ReadinessAssurance::Helpers::Ownerables
extend ActiveSupport::Concern
included do

  def read_1;   @_read_1   ||= get_user(:read_1); end
  def read_2;   @_read_2   ||= get_user(:read_2); end
  def read_3;   @_read_3   ||= get_user(:read_3); end
  def read_4;   @_read_4   ||= get_user(:read_4); end
  def read_5;   @_read_5   ||= get_user(:read_5); end
  def read_6;   @_read_6   ||= get_user(:read_6); end
  def update_1; @_update_1 ||= get_user(:update_1); end

  def team_1; @_team_1 ||= get_team(:ra_team_1_test); end
  def team_2; @_team_2 ||= get_team(:ra_team_2_test); end
  def team_3; @_team_3 ||= get_team(:ra_team_3_test); end

  def team_1_users; @_team_1_users ||= [read_1, read_2]; end
  def team_2_users; @_team_2_users ||= [read_4, read_5, read_6]; end
  def team_3_users; @_team_3_users ||= [get_user(:read_9), get_user(:read_2)]; end

end; end
