require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class CacheQueryKeyAssignment < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods

  def create_phase_state_and_score(phase, u)
    state = phase.find_or_create_state_for_ownerable(u, u)
    score = phase.find_or_create_score_for_ownerable(u, u)
    state.save  if state.new_record?
    score.save  if score.new_record?
    [state.reload, score.reload]
  end

  def create_phase_states_and_scores
    reader = serializer_read_user
    phasea = record.thinkspace_casespace_phases.first
    phaseb = record.thinkspace_casespace_phases.last
    create_phase_state_and_score(phasea, user)
    state, score = create_phase_state_and_score(phaseb, user)
    create_phase_state_and_score(phasea, reader)
    create_phase_state_and_score(phaseb, reader)
    @state_timestamp = cache_timestamp(state)
    @score_timestamp = cache_timestamp(score)
  end

  describe @assignments_controller do
    let(:user)   {serializer_update_user}
    describe 'assignment phase states' do
      let(:record) {serializer_assignment}
      let(:action) {:phase_states}

      it 'serializer options' do
        @controller.instance_variable_set(:@assignment, record)
        create_phase_states_and_scores
        serializer_options.cache ownerable: user, instance_var: :assignment
        serializer_options.cache_query_key name: :assignment
        serializer_options.cache_query_key name: :phases, maximum: :thinkspace_casespace_phases, column: :created_at
        serializer_options.cache_query_key(
          name:       :phase_states,
          scope:      [:thinkspace_casespace_phases, :scope_phase_states_by_ownerable],
          scope_args: [nil, serializer_options.cache_ownerable],
          table:      :thinkspace_casespace_phase_states,
        )
        serializer_options.cache_query_key(
          name:       :phase_scores,
          scope:      [:thinkspace_casespace_phases, :scope_phase_scores_by_ownerable],
          scope_args: [nil, serializer_options.cache_ownerable],
          table:      :thinkspace_casespace_phase_scores,
        )
        phase = record.thinkspace_casespace_phases.first
        phase.created_at = Time.now
        phase.save
        phase_timestamp = cache_timestamp(phase.reload, :created_at)
        key    = cache_key(serializer_options.cache_options)
        digest = cache_digest(key)
        # print_cache_key_and_digest(key, digest, 'Serializer options generated')
        assert_match /.*assignment\/#{cache_timestamp(record)}/, key, '==> serializer options cache key does not include assignment timestamp'
        assert_match /.*phases\/#{phase_timestamp}/, key, '==> serializer options cache key does not include phase timestamp'
        assert_match /.*phase_states\/#{@state_timestamp}/, key, '==> serializer options cache key does not include state timestamp'
        assert_match /.*phase_scores\/#{@score_timestamp}/, key, '==> serializer options cache key does not include score timestamp'
      end

    end
  end

end; end; end
