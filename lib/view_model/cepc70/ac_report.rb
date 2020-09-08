module ViewModel
  module Cepc70
    class AcReport < ViewModel::Cepc70::CommonSchema
      def related_party_disclosure
        xpath(%w[ACI-Related-Party-Disclosure])
      end

      def executive_summary
        xpath(%w[Executive-Summary])
      end

      def equipment_owner_name
        xpath(%w[Equipment-Owner Equipment-Owner-Name])
      end

      def equipment_owner_telephone
        xpath(%w[Equipment-Owner Telephone-Number])
      end

      def equipment_owner_organisation
        xpath(%w[Equipment-Owner Organisation-Name])
      end

      def equipment_owner_address_line1
        xpath(%w[Equipment-Owner Registered-Address Address-Line-1])
      end

      def equipment_owner_address_line2
        xpath(%w[Equipment-Owner Registered-Address Address-Line-2])
      end

      def equipment_owner_address_line3
        xpath(%w[Equipment-Owner Registered-Address Address-Line-3])
      end

      def equipment_owner_address_line4
        xpath(%w[Equipment-Owner Registered-Address Address-Line-4])
      end

      def equipment_owner_town
        xpath(%w[Equipment-Owner Registered-Address Post-Town])
      end

      def equipment_owner_postcode
        xpath(%w[Equipment-Owner Registered-Address Postcode])
      end

      def operator_responsible_person
        xpath(%w[Equipment-Operator Responsible-Person])
      end

      def operator_telephone
        xpath(%w[Equipment-Operator Telephone-Number])
      end

      def operator_organisation
        xpath(%w[Equipment-Operator Organisation-Name])
      end

      def operator_address_line1
        xpath(%w[Equipment-Operator Registered-Address Address-Line-1])
      end

      def operator_address_line2
        xpath(%w[Equipment-Operator Registered-Address Address-Line-2])
      end

      def operator_address_line3
        xpath(%w[Equipment-Operator Registered-Address Address-Line-3])
      end

      def operator_address_line4
        xpath(%w[Equipment-Operator Registered-Address Address-Line-4])
      end

      def operator_town
        xpath(%w[Equipment-Operator Registered-Address Post-Town])
      end

      def operator_postcode
        xpath(%w[Equipment-Operator Registered-Address Postcode])
      end

      def extract_aci_recommendations(nodes)
        nodes.map do |node|
          {
            sequence: node.at("Seq-Number").content,
            text: node.at("Text").content,
          }
        end
      end

      def key_recommendations_efficiency
        extract_aci_recommendations(
          @xml_doc.search(
            "ACI-Key-Recommendations/Sub-System-Efficiency-Capacity-Cooling-Loads/ACI-Recommendation",
          ),
        )
      end

      def key_recommendations_maintenance
        extract_aci_recommendations(
          @xml_doc.search(
            "ACI-Key-Recommendations/Improvement-Options/ACI-Recommendation",
          ),
        )
      end

      def key_recommendations_control
        extract_aci_recommendations(
          @xml_doc.search(
            "ACI-Key-Recommendations/Alternative-Solutions/ACI-Recommendation",
          ),
        )
      end

      def key_recommendations_management
        extract_aci_recommendations(
          @xml_doc.search(
            "ACI-Key-Recommendations/Other-Recommendations/ACI-Recommendation",
          ),
        )
      end

      def sub_systems
        @xml_doc
            .search("ACI-Sub-Systems/ACI-Sub-System")
            .map do |node|
          {
              volume_definitions: node.at("Sub-System-Volume-Definitions")&.content,
              id: node.at("Sub-System-ID")&.content,
              description: node.at("Sub-System-Description")&.content,
              cooling_output: node.at("Sub-System-Cooling-Output")&.content,
              area_served: node.at("Sub-System-Area-Served-Description")&.content,
              inspection_date: node.at("Sub-System-Inspection-Date")&.content,
              cooling_plant_count: node.at("Sub-System-Cooling-Plant-Count")&.content,
              ahu_count: node.at("Sub-System-AHU-Count")&.content,
              terminal_units_count: node.at("Sub-System-Terminal-Units-Count")&.content,
              controls_count: node.at("Sub-System-Controls-Count")&.content,
          }
        end
      end
    end
  end
end
