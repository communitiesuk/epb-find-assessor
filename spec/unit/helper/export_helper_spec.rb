describe Helper::ExportHelper do
  let(:helper) { described_class }

  context "when given data from the domestic recommendations open data export use-case" do
    let(:domestic_recommendations_data) do
      [
        {
          recommendations: [
            {
              assessment_id: "0000-0000-0000-0000-0000",
              improvement_code: "5",
              improvement_description: nil,
              improvement_summary: nil,
              indicative_cost: "£100 - £350",
              sequence: 1,
            },
            {
              assessment_id: "0000-0000-0000-0000-0000",
              improvement_code: "1",
              improvement_description: nil,
              improvement_summary: nil,
              indicative_cost: "2000",
              sequence: 2,
            },
          ],
        },
        {
          recommendations: [
            {
              assessment_id: "0000-0000-0000-0000-1000",
              improvement_code: "5",
              improvement_description: nil,
              improvement_summary: nil,
              indicative_cost: "£100 - £350",
              sequence: 1,
            },
            {
              assessment_id: "0000-0000-0000-0000-1000",
              improvement_code: "1",
              improvement_description: nil,
              improvement_summary: nil,
              indicative_cost: "2000",
              sequence: 2,
            },
          ],
        },
      ]
    end

    it "produces a flat array of individual recommendation hashes" do
      result =
        helper.flatten_domestic_rr_response(domestic_recommendations_data)
      expect(result).to eq [
        {
          assessment_id: "0000-0000-0000-0000-0000",
          improvement_code: "5",
          improvement_description: nil,
          improvement_summary: nil,
          indicative_cost: "£100 - £350",
          sequence: 1,
        },
        {
          assessment_id: "0000-0000-0000-0000-0000",
          improvement_code: "1",
          improvement_description: nil,
          improvement_summary: nil,
          indicative_cost: "2000",
          sequence: 2,
        },
        {
          assessment_id: "0000-0000-0000-0000-1000",
          improvement_code: "5",
          improvement_description: nil,
          improvement_summary: nil,
          indicative_cost: "£100 - £350",
          sequence: 1,
        },
        {
          assessment_id: "0000-0000-0000-0000-1000",
          improvement_code: "1",
          improvement_description: nil,
          improvement_summary: nil,
          indicative_cost: "2000",
          sequence: 2,
        },
      ]
    end
  end

  describe "Helper::ExportHelper" do
    context "when turning exported data into a csv" do
      let(:expectation) do
        'ASSESSMENT_ID,ADDRESS1,POSTCODE,BUILDING_REFERENCE_NUMBER,COMMA_TEST_VALUES,LODGEMENT_DATE
0000-0000-0000-0000-0005,"28, Joicey Court",TS26 8BZ,4504250668,"a,b,c,",13/04/2009
0000-0000-0000-0000-0101,"88, Station Lane",TS25 1DS,2469620278,"1,2",01/02/2020'
      end
    end
  end
end