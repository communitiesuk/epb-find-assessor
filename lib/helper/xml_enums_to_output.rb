module Helper
  class XmlEnumsToOutput
    RATINGS = {
      "0" => "N/A",
      "1" => "Very Poor",
      "2" => "Poor",
      "3" => "Average",
      "4" => "Good",
      "5" => "Very Good",
    }.freeze
    BUILT_FORM = {
      "1" => "Detached",
      "2" => "Semi-Detached",
      "3" => "End-Terrace",
      "4" => "Mid-Terrace",
      "5" => "Enclosed End-Terrace",
      "6" => "Enclosed Mid-Terrace",
      "NR" => "Not Recorded",
    }.freeze
    ENERGY_TARIFF = {
      "1" => "standard tariff",
      "2" => "off-peak 7 hour",
      "3" => "off-peak 10 hour",
      "4" => "24 hour",
      "ND" => "not applicable",
    }.freeze
    RDSAP_MAIN_FUEL = {
      "0" =>
        "To be used only when there is no heating/hot-water system or data is from a community network",
      "1" =>
        "mains gas - this is for backwards compatibility only and should not be used",
      "2" =>
        "LPG - this is for backwards compatibility only and should not be used",
      "3" => "bottled LPG",
      "4" =>
        "oil - this is for backwards compatibility only and should not be used",
      "5" => "anthracite",
      "6" => "wood logs",
      "7" => "bulk wood pellets",
      "8" => "wood chips",
      "9" => "dual fuel - mineral + wood",
      "10" =>
        "electricity - this is for backwards compatibility only and should not be used",
      "11" =>
        "waste combustion - this is for backwards compatibility only and should not be used",
      "12" =>
        "biomass - this is for backwards compatibility only and should not be used",
      "13" =>
        "biogas - landfill - this is for backwards compatibility only and should not be used",
      "14" =>
        "house coal - this is for backwards compatibility only and should not be used",
      "15" => "smokeless coal",
      "16" => "wood pellets in bags for secondary heating",
      "17" => "LPG special condition",
      "18" => "B30K (not community)",
      "19" => "bioethanol",
      "20" => "mains gas (community)",
      "21" => "LPG (community)",
      "22" => "oil (community)",
      "23" => "B30D (community)",
      "24" => "coal (community)",
      "25" => "electricity (community)",
      "26" => "mains gas (not community)",
      "27" => "LPG (not community)",
      "28" => "oil (not community)",
      "29" => "electricity (not community)",
      "30" => "waste combustion (community)",
      "31" => "biomass (community)",
      "32" => "biogas (community)",
      "33" => "house coal (not community)",
      "34" => "biodiesel from any biomass source",
      "35" => "biodiesel from used cooking oil only",
      "36" => "biodiesel from vegetable oil only (not community)",
      "37" => "appliances able to use mineral oil or liquid biofuel",
      "51" => "biogas (not community)",
      "56" =>
        "heat from boilers that can use mineral oil or biodiesel (community)",
      "57" =>
        "heat from boilers using biodiesel from any biomass source (community)",
      "58" => "biodiesel from vegetable oil only (community)",
      "99" => "from heat network data (community)",
    }.freeze
    SAP_MAIN_FUEL = {
      "1" => "Gas: mains gas",
      "2" => "Gas: bulk LPG",
      "3" => "Gas: bottled LPG",
      "4" => "Oil: heating oil",
      "7" => "Gas: biogas",
      "8" => "LNG",
      "9" => "LPG subject to Special Condition 18",
      "10" => "Solid fuel: dual fuel appliance (mineral and wood)",
      "11" => "Solid fuel: house coal",
      "12" => "Solid fuel: manufactured smokeless fuel",
      "15" => "Solid fuel: anthracite",
      "20" => "Solid fuel: wood logs",
      "21" => "Solid fuel: wood chips",
      "22" => "Solid fuel: wood pellets (in bags, for secondary heating)",
      "23" =>
        "Solid fuel: wood pellets (bulk supply in bags, for main heating)",
      "36" => "Electricity: electricity sold to grid",
      "37" => "Electricity: electricity displaced from grid",
      "39" => "Electricity: electricity, unspecified tariff",
      "41" => "Community heating schemes: heat from electric heat pump",
      "42" => "Community heating schemes: heat from boilers - waste combustion",
      "43" => "Community heating schemes: heat from boilers - biomass",
      "44" => "Community heating schemes: heat from boilers - biogas",
      "45" => "Community heating schemes: waste heat from power stations",
      "46" => "Community heating schemes: geothermal heat source",
      "48" => "Community heating schemes: heat from CHP",
      "49" => "Community heating schemes: electricity generated by CHP",
      "50" =>
        "Community heating schemes: electricity for pumping in distribution network",
      "51" => "Community heating schemes: heat from mains gas",
      "52" => "Community heating schemes: heat from LPG",
      "53" => "Community heating schemes: heat from oil",
      "54" => "Community heating schemes: heat from coal",
      "55" => "Community heating schemes: heat from B30D",
      "56" =>
        "Community heating schemes: heat from boilers that can use mineral oil or biodiesel",
      "57" =>
        "Community heating schemes: heat from boilers using biodiesel from any biomass source",
      "58" => "Community heating schemes: biodiesel from vegetable oil only",
      "72" => "biodiesel from used cooking oil only",
      "73" => "biodiesel from vegetable oil only",
      "74" => "appliances able to use mineral oil or liquid biofuel",
      "75" => "B30K",
      "76" => "bioethanol from any biomass source",
      "99" => "Community heating schemes: special fuel",
    }.freeze
    RDSAP_GLAZED_TYPE = {
      "1" => "double glazing installed before 2002",
      "2" => "double glazing installed during or after 2002",
      "3" => "double glazing, unknown install date",
      "4" => "secondary glazing",
      "5" => "single glazing",
      "6" => "triple glazing",
      "7" => "double, known data",
      "8" => "triple, known data",
      "ND" => "not defined",
    }.freeze
    SAP_GLAZED_TYPE = {
      "1" => "not applicable (non-glazed door)",
      "2" => "single",
      "3" => "double",
      "4" => "double low-E hard 0.2",
      "5" => "double low-E hard 0.15",
      "6" => "double low-E soft 0.1",
      "7" => "double low-E soft 0.05",
      "8" => "triple",
      "9" => "triple low-E hard 0.2",
      "10" => "triple low-E hard 0.15",
      "11" => "triple low-E soft 0.1",
      "12" => "triple low-E soft 0.05",
      "13" => "secondary glazing",
    }.freeze

    def self.xml_value_to_string(number)
      BUILT_FORM[number]
    end

    def self.energy_rating_string(value)
        RATINGS[value]
    end

    def self.energy_tariff(value)
      ENERGY_TARIFF[value]
    end

    def self.main_fuel_rdsap(value)
      RDSAP_MAIN_FUEL[value]
    end

    def self.main_fuel_sap(value)
      SAP_MAIN_FUEL[value]
    end

    def self.glazed_type_rdsap(value)
      RDSAP_GLAZED_TYPE[value]
    end

    def self.glazed_type_sap(value)
      SAP_GLAZED_TYPE[value]
    end
  end
end
