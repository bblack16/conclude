module Conclude
  class Rule < RuleBase
    include BBLib::TypeInit

    # def self.init_foundation_default_class
    #   Rules::Block
    # end

    init_foundation = true

    def self.init_foundation_default_class
      Rules::Block
    end

  end
end
