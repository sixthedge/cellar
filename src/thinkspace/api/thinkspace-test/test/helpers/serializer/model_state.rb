module Test::Serializer::ModelState

  extend ActiveSupport::Concern
  included do

    def timestamp; Time.now.utc.to_s(:nsec); end

    def get_current_ability; @controller.send(:current_ability); end

    def set_current_ability(let_method)
      @ucount = 0; @scount = 0; @acount = 0; @pcount = 0
      self.send(let_method)  # the let method should cause the creation of all the records
      ability = ability_class.new(user)
      @controller.instance_variable_set(:@current_ability, ability)
    end

    def create_model_state_user(role=:read, state=:active, user_space=space)
      first_name = "user.#{@ucount += 1}.#{role}.#{timestamp}"
      email      = "#{first_name.downcase}@sixthedge.com"
      new_user   = user_class.create(first_name: first_name, last_name:  "Doe", email: email, state: state)
      create_model_state_space_user(user_space, new_user, role, state)  if user_space.present?
      new_user
    end

    def create_model_state_space_user(user_space, new_user, role, state)
      space_user_class.create(space_id: user_space.id, user_id: new_user.id, role: role, state: state)
    end

    def create_model_state_space(state=:active)
      space_class.create(title: "Space-#{@scount+=1} : #{timestamp}", state: state)
    end

    def create_model_state_assignments
      records           = Array.new
      spaces            = [get_let_value(:spaces) || space].flatten
      assignment_states = get_assignment_states
      spaces.each do |s|
        assignment_states.each do |state, n|; n.times do; records.push create_model_state_assignment(state, s); end; end
      end
      records
    end

    def create_model_state_assignment(state=:active, s=space)
      assignment_class.create(space_id: s.id, title: "Assignment-#{@acount+=1} (space_id: #{s.id}) : #{timestamp}", state: state)
    end

    def create_model_state_phases
      records      = Array.new
      assignments  = [get_let_value(:assignments) || assignment].flatten
      phase_states = get_phase_states
      assignments.each do |a|     
        phase_states.each do |state, n|; n.times do; records.push create_model_state_phase(state, a); end; end
      end
      records
    end

    def create_model_state_phase(state=:active, a=assignment)
      phase_class.create(
        assignment_id: a.id,
        title:         "Phase-#{@pcount+=1} (assignment_id: #{a.id}) : #{timestamp}",
        position:      @pcount,
        state:         state,
      )
    end

    # ###
    # ### Assert.
    # ###

    def admin_states; ['active', 'inactive']; end
    def read_states;  ['active']; end

    def get_phase_states;      get_let_value(:phase_states)      || {active: 1, inactive: 2, neutral: 1}; end
    def get_assignment_states; get_let_value(:assignment_states) || {active: 2, inactive: 1, neutral: 1}; end

    def assert_assignments
      # space_assignments_state_sql
      serializer_options.add_attributes(:state, :assignment_id, :space_id)
      serializer_options.remove_all_except(:thinkspace_casespace_assignments, :thinkspace_casespace_phases)
      serializer_options.include_association(:thinkspace_casespace_assignments, :thinkspace_casespace_phases)
      json = serialize
      assert_kind_of Hash, json, "json should be a hash #{json.inspect}"
      sjson = json[space_class.name.underscore]
      assert_kind_of Hash, sjson, "space json should be a hash #{sjson.inspect}"
      ajson = json[assignment_class.name.underscore.pluralize]
      assert_kind_of Array, ajson, "space assignments json should be an array #{ajson.inspect}"
      pjson = json[phase_class.name.underscore.pluralize]
      assert_kind_of Array, pjson, "space phases json should be an array #{pjson.inspect}"
      actual = ajson.length
      states = get_role_states
      n      = get_number_of_records_for_states(states, get_assignment_states)
      expect = assignments.select {|a| a.space_id == space.id && states.include?(a.state)}.length
      assert_equal expect, actual,  "#{role}..should have #{expect} assignments not #{actual} for states #{states}"
      ids = sjson[assignment_class.name.underscore + '_ids'] || []
      assert_equal expect, ids.length,  "#{role}..space json should have #{expect} assignment ids not #{actual} #{ids}"
      assert_equal n, actual, "#{role}..space should have #{n} assignments not #{actual} #{ids}"
      state_assignments = assignments.select {|a| a.space_id == space.id && states.include?(a.state)}
      assert_equal expect, state_assignments.length, "assigments for states #{states} should be #{expect} not #{state_assignments.length}"
      state_assignments.each do |assignment|
        assignment_json = ajson.select {|h| h[:id] == assignment.id}
        assert_equal 1, assignment_json.length, "#{role}..should only be one assignment for id #{assignment.id} in space assignments json #{assignment_json.inspect}"
        actual = pjson.select {|h| h[:assignment_id] == assignment.id}.length
        expect = assignment.thinkspace_casespace_phases.where(state: states).count
        assert_equal expect, actual, "#{role}..should have #{expect} phases not #{actual} for states #{states}"
      end
    end

    def assert_phases
      # assignment_phases_state_sql
      serializer_options.add_attributes(:state)
      serializer_options.remove_all_except(:thinkspace_casespace_phases)
      serializer_options.include_association(:thinkspace_casespace_phases)
      json = serialize
      assert_kind_of Hash, json, "phase json should be a hash #{json.inspect}"
      ajson = json[assignment_class.name.underscore]
      assert_kind_of Hash, ajson, "assignment json should be a hash #{ajson.inspect}"
      actual = json[phase_class.name.underscore.pluralize].length
      states = get_role_states
      n      = get_number_of_records_for_states(states, get_phase_states)
      expect = phases.select {|p| p.assignment_id == assignment.id && states.include?(p.state)}.length
      assert_equal expect, actual,  "#{role}..assignment should have #{expect} phases not #{actual} for states #{states}"
      ids = ajson[phase_class.name.underscore + '_ids'] || []
      assert_equal expect, ids.length,  "#{role}..assignment should have #{expect} phase_ids not #{actual} #{ids}"
      assert_equal n, actual, "#{role}..assignment should have #{n} phases not #{actual} #{ids}"
    end

    def get_role_states; role == :read ? read_states : admin_states; end

    def get_number_of_records_for_states(states, hash)
      count = 0
      states.each {|state| count += (hash[state.to_sym] || 0)}
      count
    end

    def space_assignments_state_sql(s=space)
      puts "\n\n"
      puts "SQL space.assignments #{s.id} (#{s.state})...#{role}...:"
      print_sql(s.thinkspace_casespace_assignments)
      puts "\n\n"
    end

    def assignment_phases_state_sql(a=assignment)
      puts "\n\n"
      puts "SQL assignment.phases #{a.id} (#{a.state})...#{role}...:"
      print_sql(a.thinkspace_casespace_phases)
      puts "\n\n"
    end

    def print_sql(scope)
      states       = get_role_states
      action       = role == :owner ? :update : role
      sql          = scope.accessible_by(get_current_ability, action).to_sql
      select, from = sql.split('FROM', 2)
      puts "  FROM (raw): #{from}"
      puts "\n"
      parts = from.split(/([A-Z]+\s*[A-Z]*\s*[A-Z]*)/)
      puts "  FROM #{parts.shift}"
      parts.each do |part|
        if part.match /[A-Z]+/
          puts "    #{part}"
        else
          puts "      #{part}"
        end
      end
    end

  end

end
