describe Gateway::AssessmentLookUpsGateway do
  context "insert look up data into the table" do
    subject { Gateway::AssessmentLookUpsGateway.new }

    it "does not return a error" do
      expect { subject }.not_to raise_error
    end

    it "mocks the insert process" do
      gateway = instance_double(Gateway::AssessmentLookUpsGateway)
      allow(gateway).to receive(:insert).and_return(true)
      expect(gateway.insert(1, "test", "v", "CEPC")).to eq(true)
    end

    context "when inserting all the enum values for built_form stored in the helper class" do
      before do
        Helper::XmlEnumsToOutput::BUILT_FORM.each do |key, value|
          subject.insert(1, value, key, "CEPC")
        end
      end

      let!(:inserted_data) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT * FROM assessment_look_ups",
        )
      end

      it "returns all the relevant data from the assessment_look_ups table" do
        expect(inserted_data.rows.count).to eq(7)
        expect(inserted_data[0]["attribute_id"]).to eq(1)
        expect(inserted_data[0]["look_up_name"]).to eq("Detached")
        expect(inserted_data[0]["look_up_value"]).to eq("1")
        expect(inserted_data[0]["schema"]).to eq("CEPC")
      end
    end
  end
end
