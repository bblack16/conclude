module Conclude
  module Rules
    class Range < Attribute
      # Expressions should be structured as though they are case
      # statements, where the key will be compared to the value
      # using === and the value should be a value between 0
      # and 100 (representing a percentage).
      attr_hash :expressions, values: Numeric, arg_at: 2
      attr_float_between 0, 100, :fallback, default: 0
      # When set to true, if the expressions and value are numeric, the proximity
      # to the next closest range value will be used rather than the value of
      # the nearest match (meaning an approximate distance between the range
      # of numbers a match falls between is calculated for the score)
      attr_bool :estimate, default: true
      attr_float_between 0, 100, :threshold, default: 1

      def threshold
        0
      end

      def score(obj)
        value = extract_value(obj)
        match = nil
        score = -1

        expressions.each do |expression, num|
          next if score > num
          next unless value_match?(value, expression)
          match = expression
          score = num
        end

        score = match ? calc_estimate(value, score, match) : fallback

        weight * (score / 100.0)
      end

      def calc_estimate(value, score, match_value)
        return score if !value.is_a?(Numeric) || value == match_value

        closest = expressions.sort_by { |k, v| v }.find do |k, v|
          next if k == match_value || !k.is_a?(Numeric)
          case operator
          when :gt, :gte
            k > value
          when :lt, :lte
            k < value
          end
        end

        return score unless closest

        distance = (match_value - value) / (match_value - closest.first).to_f
        add = (closest.last - score) * distance
        score + add
      end
    end
  end
end
