describe Gateway::JsonCertificates do
  context "when reading exported json certificates from the file system" do
    subject { Gateway::JsonCertificates.new }

    let(:gateway) { instance_double(Gateway::JsonCertificates) }

    it "reads the json files from a directory" do
      path = File.join Dir.pwd, "spec/fixtures/open_data_export/csv"
      files =
        Dir
          .glob(File.join(path, "**", "*"))
          .select { |file| File.file?(file) && File.extname(file) == ".csv" }
      allow(gateway).to receive(:read).and_return(files)
      expect(gateway.read).to be_a(Array)
      expect(gateway.read.length).to eq(6)
    end
  end
end
