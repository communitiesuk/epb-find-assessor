require_relative "./reporting/open_data_export_test_helper"

def get_fixture_headers
  fixture_csv = read_csv_fixture("domestic")
  headers = fixture_csv.headers.clone.to_a
end

describe "Acceptance::AssessmentAttributeValue" do
  include RSpecRegisterApiServiceMixin

  context "When lodging assessment data import into EAV and export using data pivot" do
    before(:all) do
      scheme_id = lodge_assessor
      domestic_rdsap_xml =
        get_assessment_xml(
          "RdSAP-Schema-20.0.0",
          "0000-0000-0000-0000-0004",
          test_start_date,
        )

      domestic_rdsap_xml =
        get_assessment_xml(
          "RdSAP-Schema-20.0.0",
          "0000-0000-0000-0000-0004",
          test_start_date,
        )

      lodge_assessment(
        assessment_body: domestic_rdsap_xml.to_xml,
        accepted_responses: [201],
        auth_data: {
          scheme_ids: [scheme_id],
        },
        override: true,
      )

      domestic_sap_xml =
        get_assessment_xml(
          "SAP-Schema-18.0.0",
          "0000-0000-0000-0000-1100",
          test_start_date,
        )

      domestic_sap_building_reference_number = domestic_sap_xml.at("UPRN")
      domestic_sap_building_reference_number.children =
        "RRN-0000-0000-0000-0000-0023"
      lodge_assessment(
        assessment_body: domestic_sap_xml.to_xml,
        accepted_responses: [201],
        auth_data: {
          scheme_ids: [scheme_id],
        },
        override: true,
        schema_name: "SAP-Schema-18.0.0",
      )

      import_use_case = UseCase::ImportAssessmentAttributes.new
      import_use_case.execute
      @fixture_csv = read_csv_fixture("domestic")
    end

    let(:export_use_case) { UseCase::ExportAssessmentAttributes.new }

    let(:exported_data) do
      export_use_case.execute(@fixture_csv.headers.map(&:downcase).uniq, true)
    end

    it "can export the data based on the headers requested by ODC (in the .csv)" do
      expect(exported_data.count).to eq(2)
    end

    it "has the correct hashed id for the lodged assessments" do
      expect(exported_data.first["assessment_id"]).to eq(
        "5cb9fa3be789df637c7c20acac4e19c5ebf691f0f0d78f2a1b5f30c8b336bba6",
      )
      expect(exported_data[1]["assessment_id"]).to eq(
        "71fdb53a3a3da2cf98ae87c819dfc958866ead832a214cc960da52d2edaaaad6",
      )
    end

    it "has the correct address for the RdSAP cert" do
      expect(exported_data.first["building_reference_number"]).to eq(
        "UPRN-000000000000",
      )
      expect(exported_data.first["address1"]).to eq("1 Some Street")
      expect(exported_data.first["address2"]).to eq("")
      expect(exported_data.first["address3"]).to eq("")
    end

    it "has the correct float values" do
      expect(exported_data.first["hot_water_cost_current"].to_f).to eq(200.40)
      expect(exported_data[1]["hot_water_cost_current"].to_f).to eq(200.40)
    end

    it "has the correct address for the SAP cert" do
      expect(exported_data[1]["building_reference_number"]).to eq(
        "RRN-0000-0000-0000-0000-0023",
      )
      expect(exported_data[1]["address1"]).to eq("1 Some Street")
      expect(exported_data[1]["address2"]).to eq("Some Area")
      expect(exported_data[1]["address3"]).to eq("Some County")
    end

    it "deals with the enum strings representations" do
    end

    # get_fixture_headers.each do |header|
    #   xit "tests the attribute value: #{header} exported matches the fixture" do
    #     expect(exported_data[0][header.downcase]).to eq(@fixture_csv.first[header])
    #   end
    # end
  end
end
