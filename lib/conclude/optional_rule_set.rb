require_relative 'rule_base'
require_relative 'rule'

BBLib.scan_files(File.expand_path('../types', __FILE__), '*.rb') do |file|
  require_relative file
end

module Conclude
  class OptionalRuleSet < RuleSet

    attr_ary_of RuleBase, :rules, add_rem: true

    # Assigned score based on the weight of each matched rule.
    # This number is arbitrary.
    def score(attributes)
      rules.any? { |rule| rule.match?(attributes) } ? weight : 0
    end

    def weight
      rules.map(&:contributed_weight).max || 0
    end

  end
end
