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
    end

    it "returns the files from the directory" do
      expect(subject.execute.count).to eq(3)
    end

    it "returns an array of hashes for each json file" do
      expect(subject.execute[0]).to be_a(Hash)
      expect(subject.execute[1]).to be_a(Hash)
      expect(subject.execute[2]).to be_a(Hash)
    end
  end
end
