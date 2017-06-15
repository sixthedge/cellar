module Thinkspace; module PeerAssessment; module JsonAnonymizers
  class Review

    # ### Thinkspace::PeerAssessment::JsonAnonymizers::Review
    # ----------------------------------------
    #
    # The function of this object is to generate anonymized results for a set of reviews

    attr_reader :assessment, :reviews, :options, :data, :results

    # ### Initialization
    def initialize(assessment, reviews, options={})
      @assessment = assessment
      @reviews    = reviews
      @options    = options
      @data       = {options: get_options(@assessment, @reviews), qualitative: {}, quantitative: {}} unless @reviews.blank?
      @results    = Hash.new
    end

    def get_options(assessment, reviews)
      options = assessment.options.with_indifferent_access
      add_score_range_to_options(options, assessment, reviews)
      options
    end

    def add_score_range_to_options(options, assessment, reviews)
      min, max = assessment.get_min_max_score_for_reviews(reviews.count)
      options  = options.with_indifferent_access
      options[:points] ||= {}
      options[:points][:min] = min
      options[:points][:max] = max
      options
    end

    def process
      return Hash.new if @reviews.blank?
      process_reviews
      average_results
      @data
    end

    def process_reviews
      @reviews.each do |review|
        values = review.qualitative_item_values
        values.each do |type, array|
          @data[:qualitative][type] ||= []
          @data[:qualitative][type] << array
          @data[:qualitative][type].flatten!
        end

        values  = review.quantitative_items
        values.each do |id, attrs|
          results[id] ||= []
          value = attrs['value']
          next unless value.present?
          @results[id] << value.to_f
        end

        # Sort by category.
        items = @assessment.quantitative_items
        items.each do |item|
          id    = item['id']
          label = item['label']
          next unless id.present?
          @data[:quantitative][id] ||= {}
          @data[:quantitative][id][:label] = label
          @data[:quantitative][id][:value] = @results[id]
        end
      end
    end

    def average_results
      @results.each do |id, array|
        avg          = array.inject(0.0) { |sum, el| sum + el } / array.size
        @results[id] = avg.round(2)
      end
      @data[:quantitative] = @results
    end

  end
end; end; end