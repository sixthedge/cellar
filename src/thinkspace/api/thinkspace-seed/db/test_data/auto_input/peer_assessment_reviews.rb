class AutoInputPeerAssessmentReviews < AutoInputBase

  def process(options)
    @reviews = [options[:reviews]].flatten.compact
    error "Peer assessment options[:reviews] is blank." if @reviews.blank?
    error "Peer assessment options[:reviews] is not an array." unless @reviews.is_a?(Array)
    phases = selected_phases
    error "Peer assessment reviews phases are blank." if phases.blank?
    @assessments = assessment_class.where(authable: phases)
    error "Peer assessment reviews assessments are blank." if @assessments.blank?
    process_assessments
  end

  def process_assessments
    @assessments.each do |assessment|
      process_reviews(assessment)
    end
  end

  def process_reviews(assessment)
    @reviews.each do |hash|
      error "each review must be a hash #{hash.inspect}" unless hash.is_a?(Hash)
      name = hash[:user] || error("user is blank.\nReview: #{hash.inspect}")
      user = find_user_by_name(name)
      error "user name #{name.inspect} not found." if user.blank?
      title  = hash[:team] || error("team is blank.\nReview: #{hash.inspect}")
      team = find_team_by_title(title)
      error "team title #{title.inspect} not found." if team.blank?
      array = hash[:for_users] || error("for_users is blank.\nReview: #{hash.inspect}")
      error("for_users is not an array.\nReview: #{hash.inspect}") unless array.is_a?(Array)
      process_reviews_for_users(assessment, user, team, array)
    end
  end

  def process_reviews_for_users(assessment, user, team, array)
    array.each do |hash|
      error "for users must be a hash #{hash.inspect}" unless hash.is_a?(Hash)
      name     = hash[:user] || error("for_user :user is blank.\nFor User: #{hash.inspect}")
      for_user = find_user_by_name(name)
      error "for_user name #{name.inspect} not found.\nFor User: #{hash.inspect}" if for_user.blank?
      value    = hash[:value]
      error "for_user value is blank.\nFor User: #{hash.inspect}" if value.blank?
      create_user_review(assessment, user, team, for_user, value)
    end
  end

  def create_user_review(assessment, user, team, for_user, value)
    team_set   = find_or_create_team_set(assessment, team)
    review_set = find_or_create_review_set(team_set, user)
    review     = create_for_user_review(review_set, for_user, value)
    review
  end

  def find_or_create_team_set(assessment, team)
    options  = {assessment_id: assessment.id, team_id: team.id}
    team_set = team_set_class.find_by(options)
    return team_set if team_set.present?
    team_set = @seed.new_model(:peer_assessment, :team_set, options)
    @seed.create_error(team_set) unless team_set.save
    team_set
  end

  def find_or_create_review_set(team_set, ownerable)
    options    = {team_set_id: team_set.id, ownerable: ownerable}
    review_set = review_set_class.find_by(options)
    return review_set if review_set.present?
    review_set = @seed.new_model(:peer_assessment, :review_set, options)
    @seed.create_error(review_set)  unless review_set.save
    review_set
  end

  def create_for_user_review(review_set, for_user, value)
    options = {review_set_id: review_set.id, reviewable: for_user, value: value}
    review  = @seed.new_model(:peer_assessment, :review, options)
    @seed.create_error(review)  unless review.save
    review
  end

  def assessment_class; @_pa_assessment_class ||= @seed.model_class(:peer_assessment, :assessment); end
  def team_set_class;   @_pa_team_set_class   ||= @seed.model_class(:peer_assessment, :team_set); end
  def review_set_class; @_pa_review_set_class ||= @seed.model_class(:peer_assessment, :review_set); end

  def error(message)
    super 'Peer assessment review ' + message
  end

end # AutoInputPeerAsessmentReviews

