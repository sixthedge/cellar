module Thinkspace; module ReadinessAssurance; module ProgressReports
class Standard < Base
  attr_accessor :report, :results, :json

  # ### Querying
  def query_column; 'attempt_values'; end

  # TODO: Why does this use `metadata` and not `userdata` for the jsonb_each?
  # TODO: Determine if using `answers` here is too overzealous for streaming.
  def query_json
    joined_response_ids = response_ids.join(',')
    query = "SELECT t1.id, REPLACE(t1.value::text, '\"', '') AS choice, COUNT(t1.value) AS total FROM (SELECT key AS id, value->0 AS value FROM thinkspace_readiness_assurance_responses t, jsonb_each((t.answers)::jsonb) WHERE t.id IN (#{joined_response_ids})) t1 GROUP BY t1.id, t1.value;"
    @assessment.class.connection.select_all(query)
  end

  # ### Default HWIA values
  def default_choice_value(choice, is_correct, label, order); HashWithIndifferentAccess.new(id: choice, correct: is_correct, total: 0.0, label: label, order: order, percentages: percentages_from_decimal(0.0)); end

  # ### Parsing
  # TODO: Refactor to base?
  def parse_base_results
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
      result['id']          = id
      result['order']       = order
      result['question']    = label
      result['choices']     = choices
      result['total']       = 0.0 # ADDED, if refactor.
      result['percentages'] = percentages_from_decimal(0.0)
      r[id]                 = result
    end
    r
  end

  def parse_responses
    return if @responses.empty?
    @json = query_json
    parse_json_to_results
    parse_aggregate_results
  end

  def parse_json_to_results
    @json.each do |q|
      id      = q['id']
      choice  = q['choice'].to_i # Cast to int as the choices id value is Fixnum.
      total   = q['total']
      choices = @results[id]['choices']
      value   = choices.find {|i| i.with_indifferent_access['id'] == choice }
      next unless value.present?
      value['total']         = total
      @results[id]['total'] += total # Aggregate number of selected.
    end
  end

  def parse_aggregate_results
    @results.each do |id, data|
      data['choices'].each do |choice|
        add_percentages_to_choice(id, data, choice)
      end
    end
  end

  def parse_report
    @report['completed'] = responses_count
    @report['total']     = all_ownerables_count
    @report['average']   = report_average
    @report['results']   = flatten_results
  end

  # ### Choice helpers
  def add_percentages_to_choice(id, data, choice)
    total_responses = data['total'].to_f || 0.0
    total_selected  = choice['total'].to_f || 0.0
    (total_responses == 0.0) ? decimal = 0.0 : decimal = (total_selected / total_responses)
    choice['percentages'] = percentages_from_decimal(decimal)
  end

  # ### Processing
  def process
    @report  = HashWithIndifferentAccess.new
    @results = parse_base_results
    parse_responses
    parse_report
    @report
  end
      

end; end; end; end