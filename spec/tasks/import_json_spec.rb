describe "Import Json Rake" do
  subject(:task) { get_task("import_json_certificates") }


  context "invoke rake to import json files into EAV" do
    before do
      # allow(ENV).to receive(:[])
      # allow(ENV).to receive(:[]).with("DIR_PATH").and_return("")
      #
      # # Mocks all dependencies created directly in the task
      # allow(ApiFactory).to receive(:json_certificates_gateway).and_return(
      #   json_gateway,
      # )
      #
      # allow(ApiFactory).to receive(:assessment_attributes_gateway).and_return(
      #   import_gateway,
      # )
      #
      # allow(ApiFactory).to receive(:json_certificates_usec_case).and_return(
      #   import_usecase,
      # )
      #
      # # Define mock expectatio∂∂ns
      # allow(import_usecase).to receive(:execute).and_return(true)
    end

    # let(:json_gateway) { instance_double(Gateway::JsonCertificates) }
    # let(:import_gateway) { instance_double(Gateway::AssessmentAttributesGateway) }
    # let(:import_usecase) { instance_double(UseCase::ImportJsonCertificates) }

    it "does not raise any error" do
      expect { task.invoke }.not_to raise_error
    end

    context 'call rake with real gateways' do
      before do
        ENV["DIR_PATH"]  = "#{Dir.pwd}/spec/fixtures/json_export/"
      end

      let(:inserted_data) {
        ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as cnt FROM assessment_attribute_values").first
      }

      it 'does not raise an error' do
        expect{ subject.invoke}.not_to raise_error
      end

      it 'fills the assessment_attribute_values table with data' do
        subject.invoke
        expect(inserted_data["cnt"]).not_to eq(0)
      end

    end

  end
end
