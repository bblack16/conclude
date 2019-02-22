module Conclude
  class RuleBase
    include BBLib::Effortless
    include BBLib::TypeInit

    EXPRESSION_MODES = [:any, :all, :none].freeze

    def self.init_foundation_default_class
      Rules::Block
    end

    # Allows the rule to have a name. This is arbitrary and does not need
    # to be set.
    attr_str :name, default_proc: proc { |x| "#{x.class.to_s.method_case}_#{x.object_id}"}

    # The percentage confidence that is required to consider this rule met
    attr_float_between 0, 100, :threshold, default: 100

    # When true this rule can cause an entire set to fail if it does not match
    attr_bool :required, default: false

    # This number is arbitrary but when used in a RuleSet it sets the
    # precendence of a particular rule on the entire set.
    # (higher is greater impact on overall match)
    attr_float :weight, default: 1

    # When set to true this rule can contribute it's weight if it is met
    # but the weight value is not included as a factor in the overall confidence.
    attr_bool :boost_only, default: false

    # Sets a mode for how to handle multiple rules or expressions.
    # Sets whether all expressions/rules must match, any can match or
    # none can match.
    attr_element_of proc { |x| x.expression_modes }, :mode, default: :any

    def self.expression_modes
      EXPRESSION_MODES
    end

    # Override in subclasses. Should calculate a score for this rule.
    # Score is some number less than or equal to the weight, where
    # confidence = score / weight
    def score(obj)
      1
    end

    # Creates a percentage based confidence level based on score / weight.
    # A score can be passed in in case it was already calculated soit doesn't
    # need to be recalculated.
    def confidence(obj, score = nil)
      score = score || contributed_weight.zero? ? score(obj) : score(obj) / contributed_weight
      BBLib.keep_between(score.to_f, 0, 1.0) * 100
    end

    # True if the confidence score is greater than or equal to the threshold
    def confident?(obj, score = nil)
      confidence(obj, score) >= threshold
    end

    alias_method :match?, :confident?

    def contributed_weight
      boost_only? ? 0 : weight
    end

    protected

    def aggregation_method
      mode == :none ? :any? : "#{mode}?"
    end

  end
end
