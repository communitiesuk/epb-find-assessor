module Boundary
  class JsonDirectoryNotFound < Boundary::TerminableError
    def initialize(argument)
      super(<<~MSG.strip)
        Cannot read directory or no json files present in  #{argument}
      MSG
    end
  end
end
