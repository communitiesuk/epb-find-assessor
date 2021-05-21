describe UseCase::ImportJsonCertificates do
  context "execute import use case" do
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
  end
end
