module Test::ReadinessAssurance::Helpers::Response
extend ActiveSupport::Concern
included do

  def save_response(r=record)
    raise "Response record #{record.inspect} could not be saved." unless r.save
  end

  def score_ifat_on;  assessment_question_settings(ifat: true); end
  def score_ifat_off; assessment_question_settings(ifat: false); end

  def transition_user_team_members_on_last_user_submit_on;  assessment_submit_settings(transition_user_team_members_on_last_user_submit: true); end
  def transition_user_team_members_on_last_user_submit_off; assessment_submit_settings(transition_user_team_members_on_last_user_submit: false); end

  def assessment_submit_settings(submit_settings={})
    settings = (assessment.settings || Hash.new).deep_symbolize_keys
    submit   = (settings[:submit] ||= Hash.new)
    submit.merge!(submit_settings)
    assessment_settings(settings)
  end

  def assessment_question_settings(question_settings={})
    settings  = (assessment.settings || Hash.new).deep_symbolize_keys
    questions = (settings[:questions] ||= Hash.new)
    questions.merge!(question_settings)
    assessment_settings(settings)
  end

  def scoring_settings(scoring_settings={})
    settings = (assessment.settings || Hash.new).deep_symbolize_keys
    scoring  = (settings[:scoring] ||= Hash.new)
    scoring.merge!(scoring_settings)
    assessment_settings(settings)
  end

  def assessment_settings(settings)
    assessment.settings = settings
    raise "Assessment record #{assessment.inspect} could not be saved." unless assessment.save
  end

  def get_metadata(r=record); r.reload; (r.metadata || Hash.new).deep_symbolize_keys; end
  def get_userdata(r=record); r.reload; (r.userdata || Hash.new).deep_symbolize_keys; end

  def print_data(r=nil); print_test_name; print_metadata(r); print_userdata(r); end

  def print_metadata(r=nil)
    r ||= get_response
    r.reload
    o = r.ownerable
    a = r.authable
    puts "\n---------------------Response Metadata id=#{r.id} -> Phase id=#{a.id} #{a.title} -> Ownerable id=#{o.id} #{o.class.name.demodulize}: #{o.title} -> Score: #{r.score}"
    pp r.metadata
  end

  def print_userdata(r=nil)
    r ||= get_response
    r.reload
    o = r.ownerable
    a = r.authable
    puts "\n---------------------Response Userdata id=#{r.id} -> Phase id=#{a.id} #{a.title} -> Ownerable id=#{o.id} #{o.class.name.demodulize}: #{o.title} -> Score: #{r.score}"
    pp r.userdata
  end

end; end
