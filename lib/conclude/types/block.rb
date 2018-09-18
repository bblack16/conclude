module Conclude
  module Rules
    class Block < Rule

      attr_of Proc, :block, arg_at: :block, required: true
      attr_float_between 0, 100, :threshold, default: 1

      def score(obj)
        # return 0 unless self.block
        case value = self.block.call(obj)
        when Numeric
          BBLib.keep_between(value, 0, weight)
        when TrueClass
          weight
        when FalseClass, NilClass
          0
        else
          # TODO Other cases?
          0
        end
      rescue => e
        BBLib.logger.warn("An error occurred while processing a rule (#{name}). It will be treated as a score of 0. Error: #{e}")
        0
      end

    end
  end
end
