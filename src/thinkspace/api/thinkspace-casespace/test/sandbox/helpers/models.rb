module Test::Sandbox::Helpers::Models
extend ActiveSupport::Concern
included do

  # Keep the space and case names in sync with the 'test' seed (is using 'db/test_data/staging/_config_sandbox.yml'). 
  def seed_config
    @_seed_config ||= begin
      file = File.expand_path("../../../../db/test_data/staging/_config_sandbox.yml", __FILE__)
      raise "Sandbox staging config file #{file.inspect} not found and is required for the sandbox tests." unless File.file?(file)
      YAML.load(File.read(file)).deep_symbolize_keys
    end
  end

  def user_cases
    cases = [sandbox_assignment]
    ckey  = "case_#{user.first_name}"
    seed_config.each do |key, value|
      cases.push(get_assignment(value)) if key.to_s.start_with?(ckey)
    end
    cases
  end

  def not_sandbox_space_title;      'NOT Sandbox Space'; end
  def not_sandbox_assignment_title; 'NOT Sandbox Case'; end

  def not_sandbox_space; get_space(not_sandbox_space_title); end
  def sandbox_space;     get_space(seed_config[:space_master]); end

  def read_1_space; @_read_1_space ||= get_space(seed_config[:space_read_1]); end
  def read_2_space; @_read_2_space ||= get_space(seed_config[:space_read_2]); end
  def read_3_space; @_read_3_space ||= get_space(seed_config[:space_read_3]); end

  def not_sandbox_assignment; get_assignment(not_sandbox_assignment_title); end
  def sandbox_assignment;     get_assignment(seed_config[:case_master]); end

  def read_1_sandbox_phase; @_read_1_sandbox_phase ||= sandbox_assignment.thinkspace_casespace_phases.first; end

  def create_not_sandbox_models
    space      = space_class.create(title: not_sandbox_space_title, state: :active)
    space_user = space_user_class.create(user_id: user.id, space_id: space.id, role: :read, state: :active)
    assignment = create_not_sandbox_assignment(space)
    [space, assignment, space_user]
  end

  def create_not_sandbox_assignment(space)
    assignment = assignment_class.create(title: not_sandbox_assignment_title, space_id: space.id, state: :active)
    assignment.get_or_set_timetable_for_self(due_at: Time.now + 7.days, release_at: Time.now - 7.days)
    assignment
  end

end; end
