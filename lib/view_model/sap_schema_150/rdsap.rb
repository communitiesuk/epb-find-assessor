module ViewModel
  module SapSchema150
    class Rdsap < ViewModel::SapSchema150::CommonSchema
      def property_age_band
        xpath(%w[Construction-Age-Band])
      end

      def mechanical_ventilation
        xpath(%w[Mechanical-Ventilation])
      end

      def window_description
        xpath(%w[Window Description])
      end

      def window_energy_efficiency_rating
        xpath(%w[Window Energy-Efficiency-Rating])
      end

      def window_environmental_efficiency_rating
        xpath(%w[Window Environmental-Efficiency-Rating])
      end

      def all_wall_descriptions
        @xml_doc.search("Wall/Description").map(&:content)
      end

      def all_wall_energy_efficiency_rating
        @xml_doc.search("Wall/Energy-Efficiency-Rating").map(&:content)
      end

      def all_wall_env_energy_efficiency_rating
        @xml_doc.search("Wall/Environmental-Efficiency-Rating").map(&:content)
      end

      def glazed_area
        xpath(%w[Glazed-Area])
      end
    end
  end
end
