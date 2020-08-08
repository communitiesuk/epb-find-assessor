module ViewModel
  class RdSapWrapper
    TYPE_OF_ASSESSMENT = "RD_SAP".freeze

    def initialize(xml, schema_type)
      case schema_type
      when "RdSAP-Schema-20.0.0"
        @view_model = ViewModel::RdSapSchema200::CommonSchema.new xml
      when "RdSAP-Schema-NI-20.0.0"
        @view_model = ViewModel::RdSapSchemaNi200::CommonSchema.new xml
      else
        raise ArgumentError, "Unsupported schema type"
      end
    end

    def type
      :RdSAP
    end

    def to_hash
      { type_of_assessment: "RdSAP" }
    end

    def get_view_model
      @view_model
    end
  end
end