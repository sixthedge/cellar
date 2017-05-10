module Test::Clone::Assert
  extend ActiveSupport::Concern
  included do

    def assert_clone_attributes(*args)
      record = args.shift
      cloned = args.shift
      attrs  = [args].flatten.map {|a| a.to_s}
      assert_equal true, cloned.present?, 'the record was cloned'
      refute_equal record.id, cloned.id, 'cloned record has new id'
      except_attrs = ['id', 'created_at', 'updated_at'] + attrs
      assert_equal record.attributes.except(*except_attrs), cloned.attributes.except(*except_attrs), 'record attributes are the same'
    end

    # The options[:keep_title] must be reset correctly since will be set to true for full clones of assignments and phases.
    def assert_clone_title(record, cloned_record, options)
      if options[:keep_title]
        assert_equal record.title, cloned_record.title, "the cloned title [id: #{cloned_record.id}] matches the original [id: #{record.id}]"
      elsif title = options[:title]
        assert_equal title.to_s, cloned_record.title, 'the cloned title matches the options title'
      else
        assert_equal 'clone: ' + record.title, cloned_record.title, 'clone: prepended to title'
      end
    end

    def assert_space_clone(space, cloned_space, options={})
      dictionary        = get_dictionary(options)
      except_attributes = [:title, :state, options[:except_attributes]].flatten.compact
      assert_clone_attributes(space, cloned_space, except_attributes)
      assert_clone_title(space, cloned_space, options)
      spaces = dictionary['thinkspace/common/spaces'.to_sym]
      assert_kind_of Hash, spaces, 'spaces is a hash'
      assert_equal [space], spaces.keys, 'is original space'
      assignments = dictionary['thinkspace/casespace/assignments'.to_sym]
      assert_kind_of Hash, assignments, 'space assignments is a hash'
      assignments.each do |record, cloned|
        assert_equal cloned_space.id, cloned.space_id, 'is a phase for the cloned space'
      end
    end

    def assert_assignment_clone(assignment, cloned_assignment, options={})
      dictionary        = get_dictionary(options)
      except_attributes = [:title, :state, options[:except_attributes]].flatten.compact
      assert_clone_attributes(assignment, cloned_assignment, except_attributes)
      assert_clone_title(assignment, cloned_assignment, options)
      assert_equal false, cloned_assignment.active?, 'cloned assignment is inactive'
      assignments = dictionary['thinkspace/casespace/assignments'.to_sym]
      assert_kind_of Hash, assignments, 'assignments is a hash'
      assert_equal [assignment], assignments.keys, 'is original assignment'
      phases = dictionary['thinkspace/casespace/phases'.to_sym]
      assert_kind_of Hash, phases, 'assignment phases is a hash'
      phases.each do |record, cloned|
        assert_equal cloned_assignment.id, cloned.assignment_id, 'is a phase for the cloned assignment'
        assert_equal record.title, cloned.title, 'phase titles are the same in an assignment clone'
      end
    end

    def assert_phase_clone(phase, cloned_phase, options={})
      dictionary        = get_dictionary(options)
      except_attributes = [:title, :state, :position, :phase_template_id, options[:except_attributes]].flatten.compact
      assert_clone_attributes(phase, cloned_phase, except_attributes)
      assert_clone_title(phase, cloned_phase, options)
      assert_equal true, cloned_phase.active?, 'cloned phase is active'
      key    = phase.get_record_dictionary_key(phase)
      phases = dictionary[key]
      assert_kind_of Hash, phases, 'phases is a hash'
      assert_equal [phase], phases.keys, 'is original phase'
      # assert_phase_components(cloned_phase, dictionary, options)
    end

    def assert_phase_components(cloned_phase, dictionary, options={})
      phase_key         = cloned_phase.get_record_dictionary_key(cloned_phase)
      except_attributes = [:title, :description, :configurable_id, :authable_id, :componentable_id]
      cloned_id         = cloned_phase.id
      dictionary.each do |key, hash|
        next if key == phase_key
        hash.each do |from, to|
          assert_clone_attributes(from, to, except_attributes)
          assert_equal cloned_id, to.configurable_id  if from.configurable_id.present?
          assert_equal cloned_id, to.authable_id      if from.authable_id.present?
          # assert_equal cloned_id, to.componentable_id if from.componentable_id.present?
        end
      end
    end

    def assert_input_elements_clone(*args)
      phase        = args.shift
      cloned_phase = args.shift
      dictionary   = args.shift
      elements     = dictionary['thinkspace/input_element/elements'.to_sym]
      assert_kind_of Hash, elements, 'has input elements'
      elements.each do |record, cloned|
        assert_clone_attributes(record, cloned, :phase_id, :helper_embedable_id)
        assert_equal phase.id, record.phase_id, 'input element has original phase id'
        assert_equal cloned_phase.id, cloned.phase_id, 'cloned input element has cloned phase id'
        key               = record.helper_embedable_type.underscore.pluralize.to_sym
        helper_embedables = dictionary[key]
        assert_kind_of Hash, helper_embedables, 'dictionary input element has helper embedables'
        assert_equal true, extract_phase_clone_ids(helper_embedables).include?(cloned.helper_embedable_id), 'input element has tool'
      end
    end

    def extract_phase_clone_ids(records)
      records.collect { |record, cloned| cloned.id }
    end

  end # included
end
