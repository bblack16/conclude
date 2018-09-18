module Conclude
  module Rules
    class Attribute < Rule

      COMPARISON_OPERATORS = [
        :eq, :neq, :gt, :gte, :lt, :lte, :match, :custom
      ].freeze

      attr_of [String, Symbol], :attribute, required: true, arg_at: 0
      attr_element_of COMPARISON_OPERATORS, :operator, default: :eq, arg_at: 1, pre_proc: proc { |x| x.to_sym }
      attr_ary :expressions, arg_at: 2
      attr_of Proc, :comparitor, arg_at: :block
      attr_of Proc, :processor, allow_nil: true, default: nil

      def score(obj)
        value = extract_value(obj)

        match = expressions.send(aggregation_method) do |expression|
          value_match?(value, expression)
        end

        overall = mode == :none ? !match : match
        overall ? weight : 0
      end

      def value_match?(value, expression)
        send(operator, value, expression)
      rescue => _e
        false
      end

      def extract_value(obj)
        return obj if attribute == :self
        value = case obj
        when Hash
          obj.hpath(attribute).first
        else
          obj.respond_to?(attribute) && obj.method(attribute).arity == 0 ? obj.send(attribute) : nil
        end
        return value unless processor
        processor.call(value)
      end

      def eq(a, b)
        a == b
      end

      def neq(a, b)
        a != b
      end

      def gt(a, b)
        a > b
      end

      def gte(a, b)
        a >= b
      end

      def lt(a, b)
        a < b
      end

      def lte(a, b)
        a <= b
      end

      def match(a, b)
        a =~ b
      end

      def custom(a, b)
        comparitor.call(a, b) ? true : false
      end
    end
  end
end
