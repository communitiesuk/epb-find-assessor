describe UseCase::ImportJsonCertificates do
  context "execute import use case" do
    subject { described_class.new(gateway) }

    let(:gateway) { instance_double(Gateway::JsonCertificates) }

    before do
      path = File.join Dir.pwd, "spec/fixtures/json_export/"
      files =
        Dir
          .glob(File.join(path, "**", "*"))
          .select { |file| File.file?(file) && File.extname(file) == ".json" }
      allow(gateway).to receive(:read).and_return(files)
    end

    it "returns the files from the directory" do
      expect(subject.execute.count).to eq(3)
    end
  end
end
