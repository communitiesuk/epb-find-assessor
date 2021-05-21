module UseCase
  class ImportJsonCertificates
    attr_accessor :file_gateway, :assessment_attribute_gateway

    def initialize(file_gateway, assessment_gateway)
      @file_gateway = file_gateway
      @assessment_attribute_gateway = assessment_gateway
    end

    def execute
      files = @file_gateway.read
      files.each do |f|
        certificate = JSON.parse(File.read(f))
        assessment_id = certificate["assessment_id"]
        begin
          save_atttributes(assessment_id, certificate)
        rescue Boundary::DuplicateAttribute
        end
      end
    end

  private

    def save_atttributes(assessment_id, certificate)
      certificate.each do |_key, _value|
        if _value.class == Hash &&
            _value.symbolize_keys.keys != %i[description value]
          save_atttributes(assessment_id, _value)
        else
          attribute = {
            attribute: _key.to_s,
            value: _value.class == Array ? _value.join("|") : _value,
            assessment_id: assessment_id,
          }
          save_attribute_data(attribute)
        end
      end
    end

    def save_attribute_data(attribute)
      @assessment_attribute_gateway.add_attribute_value(
        attribute[:assessment_id],
        attribute[:attribute],
        attribute[:value],
      )
    end
  end
end
