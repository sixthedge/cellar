module Thinkspace; module ReadinessAssurance; module ProgressReports
class Ifat < Base
  attr_accessor :report, :results, :json

  # ### JSONB Querying
  def query_column; 'attempt_values'; end

  def query_json
    joined_response_ids = response_ids.join(',')
    query      = "SELECT t1.k AS id, REPLACE(t1.element::text, '\"', '') AS choice, t1.number AS attempt, COUNT(t1.number) FROM (SELECT r.k, e.element, e.number FROM thinkspace_readiness_assurance_responses AS t, jsonb_each((t.userdata->'#{query_column}')::jsonb) AS r(k, v), jsonb_array_elements(r.v) WITH ORDINALITY AS e(element, number) WHERE t.id IN (#{joined_response_ids})) AS t1 GROUP BY t1.k, t1.element, t1.number ORDER BY t1.k;"
    @assessment.class.connection.select_all(query)
  end

  # ### Default HWIA values
  def default_choice_value(choice, is_correct, label, order); HashWithIndifferentAccess.new(id: choice, attempts: [], correct: is_correct, total: 0.0, total_choices: 0.0, label: label, order: order); end
  def default_attempt_value(attempt); HashWithIndifferentAccess.new(count: 0, attempt: attempt, percentages: percentages_from_decimal(0.0)); end

  # ### Parsing
  # Initial JSON will contain the following:
  # @columns=["id", "choice", "attempt", "count"],
  # @hash_rows=nil,
  # @rows=
  #   [["ra_1_1", "a", 1, 1],
  #   ["ra_1_10", "a", 2, 1],
  #   ["ra_1_10", "b", 3, 1],
  #   ["ra_1_10", "c", 1, 1]]
  # Note: Query could likely be refined to not require any post-processing.
  def parse_json_to_results
    # Loop through each of the query rows and aggregate/count the overall question data.
    @json.each do |q|
      id      = q['id']
      attempt = q['attempt']
      count   = q['count']
      choice  = q['choice']
      value   = @results[id]['choices'].find {|i| i.with_indifferent_access['id'] == choice }
      next unless value.present?
      value['total']         += count
      value['total_choices'] += (attempt.to_f * count.to_f)
      attempt                 = HashWithIndifferentAccess.new(attempt: attempt, count: count)
      value['attempts'].push attempt
    end
  end

  def parse_aggregate_results
    # Parse things that require them to be condensed via `parse_json_to_results`
    @results.each do |id, data|
      data['choices'].each do |choice|
        add_statistics_to_choice(choice)
        add_all_attempts_to_choice(id, choice)
        add_concerning_question(id, choice)
      end
    end
  end

  def parse_report
    # High level report values / flattening of the results to an array.
    parse_aggregate_results
    @report['completed'] = responses_count
    @report['total']     = all_ownerables_count
    @report['average']   = report_average
    @report['results']   = flatten_results
  end

  def parse_responses
    return if @responses.empty?
    @json = query_json
    parse_json_to_results
    parse_aggregate_results
  end

  def parse_base_results
    # Return a results Hash that contains a skeleton of the report data.
    r = HashWithIndifferentAccess.new
    @assessment.questions.each_with_index do |question, order|
      result    = HashWithIndifferentAccess.new
      choices   = Array.new
      id        = question['id']
      label     = question['question']
      q_choices = choices_for_question_id(id)
      q_choices.each_with_index do |choice, c_order|
        c_id      = choice['id']
        c_label   = choice['label']
        c_correct = (answer_for_question_id(id) == c_id)
        c_value   = default_choice_value(c_id, c_correct, c_label, c_order)
        choices.push(c_value)
      end
      result['id']       = id
      result['order']    = order
      result['question'] = label
      result['choices']  = choices
      r[id] = result
    end
    r
  end

  # ### Choice helpers
  def add_statistics_to_choice(choice)
    # Add percentage to choice that represents what percentage of all responses chose the choice at that ordinality (e.g. 33% of students chose "a" as their second attempt).
    # Add average number of attempts to get the choice (mainly useful for the correct answer).
    total         = choice['total'].to_f
    total_choices = choice['total_choices'].to_f
    choice['attempts'].each do |data|
      attempt            = data['attempt']
      count              = data['count']
      decimal            = count.to_f / total
      data['percentages'] = percentages_from_decimal(decimal)
    end
    choice['average']  = (total_choices / total).round(2).to_f
  end

  def add_all_attempts_to_choice(id, choice)
    # Ensure that each choice has all possible attempts.
    # => Makes sure a nil attempt is added if (e.g.) no-one got an answer on the first try.
    # => Allows for full rendering of an IFAT progress report that does not have responses.
    choices = choices_for_question_id(id)
    if choice['attempts'].length != choices.length
      (1..choices.length).each do |i|
        attempt = choice['attempts'].find { |x| x['attempt'] == i }
        next if attempt.present?
        attempt = default_attempt_value(i)
        choice['attempts'].push(attempt)
      end
    end
  end

  def add_concerning_question(id, choice)
    correct = choice['correct']
    return unless correct # Ignore incorrect choices.
    average = choice['average'].to_f || 0.0
    add_concerning_question_to_report(id) if average > concerning_threshold
  end

  def add_concerning_question_to_report(id)
    @report['concerns'] ||= []
    @report['concerns'].push(id) unless @report['concerns'].include?(id)
  end

  def concerning_threshold; 2; end

  # ### Processing
  def process
    # Varies due to the progress reporting needs for IF-AT differing from standard.
    @report  = HashWithIndifferentAccess.new
    @results = parse_base_results
    parse_responses
    parse_report
    @report
  end

end; end; end; end