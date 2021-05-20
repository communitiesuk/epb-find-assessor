module UseCase
  class ImportJsonCertificates
    attr_accessor :file_gateway, :assessment_attribute_gateway

    def initialize(file_gateway, assessment_gateway)
      @file_gateway = file_gateway
      @assessment_attribute_gateway = assessment_gateway
    end

    def execute
      arr = []
      files = @file_gateway.read
      files.each do |f|
        certificate = JSON.parse(File.read(f))
        save_attribute_data(certificate)
        arr << certificate
      end

      arr
    end

  private

    def save_attribute_data(certificate)
      certificate.each do |_key, _value|
        @assessment_attribute_gateway.add_attribute_value("001", "a", "c")
      end
    end
  end
end
