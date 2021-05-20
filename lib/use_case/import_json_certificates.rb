module UseCase
  class ImportJsonCertificates
    attr_accessor :file_gateway

    def initialize(file_gateway)
      @file_gateway = file_gateway
    end

    def execute
      arr = []
      files = @file_gateway.read
      files.each { |f| arr << JSON.parse(File.read(f)) }

      arr
    end
  end
end
