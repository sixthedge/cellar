module Test::Timetable::Helpers::Assert
extend ActiveSupport::Concern
included do

  def assert_open_assignments(expect=assignments.to_ary)
    actual = assignments.scope_open(ownerable).to_ary
    assert_equal expect, actual, 'open assignments returned'
  end

  def assert_open_assignments_with_ownerable(timeframe=nil)
    create_ownerable_timetable(when: timeframe)
    expect = timeframe.blank? ? assignments.to_ary : assignments - [timeable]
    assert_open_assignments(expect)
  end

  def assert_open_phases_default_to_assignment(expect=phases.order(:id).to_ary)
    actual = phases.scope_open(ownerable).to_ary
    assert_equal expect, actual, 'open phases returned'
  end

  def assert_open_phases(timeframe=nil)
    create_timetable(when: timeframe)
    expect = timeframe.blank? ? phases.to_ary : phases - [timeable]
    actual = phases.scope_open(ownerable).to_ary
    assert_equal expect, actual, 'open phases returned'
  end

  def assert_open_phases_with_ownerable(timeframe=nil)
    create_ownerable_timetable(when: timeframe)
    expect = timeframe.blank? ? phases.to_ary : phases - [timeable]
    actual = phases.scope_open(ownerable).to_ary
    assert_equal expect, actual, 'open phases returned'
  end

  def assert_times_equal(expect, actual)
    assert_equal true, expect.is_a?(Time), 'expect is a Time object'
    assert_equal true, actual.is_a?(Time), 'actual is a Time object'
    et = expect.utc.to_i
    at = actual.utc.to_i
    assert_equal et, at, "times '#{expect}' and '#{actual}' are equal"
  end

end; end
