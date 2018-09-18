require_relative 'rule_base'
require_relative 'rule'

BBLib.scan_files(File.expand_path('../types', __FILE__), '*.rb') do |file|
  require_relative file
end

module Conclude
  class RuleSet < RuleBase

    attr_ary_of RuleBase, :rules, add_rem: true

    def add(*args, &block)
      if args.size == 1 && args.first.is_a?(RuleBase)
        add_rules(args.first)
      else
        add_rules(RuleBase.new(*args, &block))
      end
    end

    # Assigned score based on the weight of each matched rule.
    # This number is arbitrary.
    def score(attributes)
      raise EmptyRuleSetException, 'Empty rule sets cannot provide a score. Add a rule first.' if rules.empty?
      rules.inject(0) do |score, rule|
        return 0 if !rule.match?(attributes) && rule.required?
        score += rule.score(attributes)
      end
    end

    def weight
      rules.inject(0) { |sum, rule| sum += rule.contributed_weight }
    end

    def results(object)
      rules.hmap do |rule|
        [rule.name, rule.confidence(object)]
      end
    end

  end
end
