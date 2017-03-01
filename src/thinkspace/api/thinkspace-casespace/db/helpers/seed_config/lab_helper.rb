#########################################################################################
# ###
# ### Labs.
# ###
# Lab chart configurations are saved in an instance variable.
# The lab charts, categories and results are create when the componentable is created from the section's configuration.
def casespace_seed_config_add_labs(config)
  lab_charts                 = config[:lab_charts] || Hash.new
  lab_charts_from_blueprints = config[:lab_charts_from_blueprints]
  return if lab_charts.blank? && lab_charts_from_blueprints.blank?
  casespace_seed_config_message('++Adding seed config lab charts.', config)
  charts = get_casespace_lab_charts
  lab_charts.each {|name, chart|  @seed.error "Lab chart name #{name.inspect} is a duplicate."  if charts.has_key?(name)}
  charts.merge!(lab_charts)
  blueprint_charts = get_casespace_lab_charts_from_blueprints(config, lab_charts_from_blueprints)
  blueprint_charts.each {|name, chart|  @seed.error "Lab blueprint chart name #{name.inspect} is a duplicate."  if charts.has_key?(name)}
  charts.merge! blueprint_charts
end

def get_casespace_lab_charts_from_blueprints(config, blueprint_charts)
  @seed.error "Lab blueprint charts are not a hash [#{blueprint_charts.inspect}]."  unless blueprint_charts.kind_of?(Hash)
  blueprints = config[:blueprints]
  @seed.error "Lab blueprints are blank."  if blueprints.blank?
  chart_hash = Hash.new

  blueprint_charts.each do |name, hash|
    chart = chart_hash[name] = Hash.new
    chart[:title]    = hash[:title]
    chart_categories = chart[:categories] = Array.new
    lab_categories = [hash[:categories]].flatten.compact
    lab_categories.each do |category_hash|
      blueprint_name = category_hash[:blueprint]
      blueprint      = get_casespace_lab_blueprint(blueprints, blueprint_name)
      category_title = category_hash[:title] || ''
      category_title = category_title.strip
      category_title += " (bp: #{blueprint_name})"  if config[:add_blueprint_name].present?
      category        = blueprint.deep_merge(category_hash.merge(title: category_title).except(:blueprint, :results))
      chart_categories.push category
      results     = category[:results] = Array.new
      lab_results = [category_hash[:results]].flatten.compact
      lab_results.each_with_index do |result_hash, index|
        result_blueprint_name = result_hash[:blueprint]
        blueprint             = get_casespace_lab_blueprint(blueprints, result_blueprint_name)
        result_title  = result_hash[:title] || blueprint[:title] || 'result'
        result_title  = "#{result_title}_#{index+1}"
        result_title += " (bp: #{result_blueprint_name})"  if config[:add_blueprint_name].present?
        results.push blueprint.deep_merge(result_hash.merge(title: result_title).except(:blueprint))
      end
    end
  end

  chart_hash
end

def get_casespace_lab_blueprint(blueprints, name)
  @seed.error "Lab blueprint name #{name.inspect} is blank."  if name.blank?
  name = name.to_sym
  @seed.error "Lab blueprint name #{name.inspect} not found."  unless blueprints.has_key?(name)
  blueprints[name]
end

#########################################################################################
# ###
# ### Lab Phase Componentable.
# ###
def create_casespace_phase_componentable_lab(phase, section, common_component, config)
  chart_name = config
  @seed.error "Phase #{phase.title.inspect} section #{section.inspect} chart name is blank."  if chart_name.blank?
  chart_hash = get_casespace_lab_charts[chart_name.to_sym]
  @seed.error "Phase #{phase.title.inspect} section #{section.inspect} chart name #{chart_name.inspect} not found."  if chart_hash.blank?
  title = chart_hash[:title] || "#{common_component.title} - #{section}"
  chart = create_lab_chart authable: phase, title: title
  add_casespace_lab_chart_section_records(chart, chart_hash)
  chart
end

def  add_casespace_lab_chart_section_records(chart, chart_hash)
  categories = [chart_hash[:categories]].flatten.compact
  categories.each_with_index do |hash, category_position|
    title    = hash[:title] || 'No category title'
    category = create_lab_category(
          title:       title,
          chart:       chart,
          position:    category_position + 1,
          description: hash[:description],
          value:       hash[:value],
          metadata:    hash[:metadata],
    )
    results = [hash[:results]].flatten.compact
    results.each_with_index do |result_hash, result_position|
      result = create_lab_result(result_hash.merge(category: category, position: result_position + 1))
    end
  end
end

