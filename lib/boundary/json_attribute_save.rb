module Boundary
  class JsonAttributeSave < Boundary::TerminableError
    def initialize(attribute)
      super(<<~MSG.strip)
        Unable to save attribute #{attribute}
      MSG
    end
  end
end
