describe UseCase::ImportJsonCertificates do
  context "call import use case with mocked gateway" do
    subject do
      described_class.new(directory_gateway, assessment_attribute_gateway)
    end

    let(:directory_gateway) { instance_double(Gateway::JsonCertificates) }

    let(:assessment_attribute_gateway) do
      instance_double(Gateway::AssessmentAttributesGateway)
    end

    before do
      path = File.join Dir.pwd, "spec/fixtures/json_export/"
      files =
        Dir
          .glob(File.join(path, "**", "*"))
          .select { |file| File.file?(file) && File.extname(file) == ".json" }
      allow(directory_gateway).to receive(:read).and_return(files)

      allow(assessment_attribute_gateway).to receive(:add_attribute_value)
        .and_return(1)
    end

    it "returns a hash for each attribute" do
      expect(subject.execute).to be_truthy
    end

    context "when use case uses the actual attribute gateway" do
      before do
        use_case =
          UseCase::ImportJsonCertificates.new(
            directory_gateway,
            Gateway::AssessmentAttributesGateway.new,
          )
        use_case.execute
      end

      let(:imported_data) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT * FROM assessment_attribute_values",
        )
      end

      it "the assessment_attribute_values table has data inserted data from the json files" do
        expect(imported_data.rows.count).not_to eq(0)
      end

      it ""
    end
  end
end
