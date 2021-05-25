describe "ImportJson" do
  subject(:task) { get_task("import_json_certificates") }
  let(:json_gateway) { instance_double(Gateway::JsonCertificates) }
  let(:import_gateway) { instance_double(Gateway::AssessmentAttributesGateway) }
  let(:import_usecase) { instance_double(UseCase::ImportJsonCertificates) }

  context "invoke rake to import json files into EAV" do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("json_dir_path").and_return("")

      # Mocks all dependencies created directly in the task
      allow(ApiFactory).to receive(:json_certificates_gateway).and_return(
        json_gateway,
      )

      allow(ApiFactory).to receive(:assessment_attributes_gateway).and_return(
        import_gateway,
      )

      allow(ApiFactory).to receive(:json_certificates_usec_case).and_return(
        import_usecase,
      )

      # Define mock expectatio∂∂ns
      allow(import_usecase).to receive(:execute).and_return(true)
    end

    it "does not raise any error" do
      expect { task.invoke }.not_to raise_error
    end

    context "when no path is specified" do
      before { allow(ENV).to receive(:[]) }
      it "does not raise any error" do
        expect { task.invoke }.to raise_error(Boundary::ArgumentMissing)
      end
    end
  end
end
