module ViewModel
  class Factory
    TYPES_OF_CEPC = %w[CEPC-8.0.0].freeze
    def create(xml, schema_type)
      if TYPES_OF_CEPC.include? schema_type
        xml_doc = Nokogiri.XML(xml).remove_namespaces!
        report_type = xml_doc.at("Report-Type").content
        case report_type
        when "3"
          ViewModel::Cepc::CepcWrapper.new(xml, schema_type)
        when "4"
          ViewModel::CepcRr::CepcRrWrapper.new(xml, schema_type)
        else
          raise ArgumentError, "Invalid CEPC report type"
        end
      end
    end
  end
end
