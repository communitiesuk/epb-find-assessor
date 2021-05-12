describe ViewModel::Export::DomesticExportView do
  include RSpecRegisterApiServiceMixin

  context "When building a domestic SAP export" do
    before { Timecop.freeze(Time.utc(2021, 5, 10, 16, 45)) }
    after { Timecop.return }

    let(:export) { read_json_fixture("sap") }

    subject do
      schema_type = "SAP-Schema-18.0.0".freeze
      build_subject(schema_type)
    end

    it "matches the expected JSON" do
      expect(subject.build).to eq(export)
    end
  end

  context "When building a domestic RdSAP export" do
    before { Timecop.freeze(Time.utc(2021, 5, 10, 16, 45)) }
    after { Timecop.return }

    let(:export) { read_json_fixture("rdsap") }

    subject do
      schema_type = "RdSAP-Schema-20.0.0".freeze
      build_subject(schema_type)
    end

    it "matches the expected JSON" do
      expect(subject.build).to eq(export)
    end
  end

  def build_subject(schema_type)
    xml = Nokogiri.XML Samples.xml(schema_type)

    scheme_id = add_scheme_and_get_id
    add_super_assessor(scheme_id)
    lodge_assessment(
      assessment_body: xml.to_s,
      schema_name: schema_type,
      auth_data: {
        scheme_ids: [scheme_id],
      },
    )

    wrapper = ViewModel::Factory.new.create(xml.to_s, schema_type)
    gateway = Gateway::AssessmentsSearchGateway.new
    assessment_id = wrapper.get_view_model.assessment_id
    assessment = gateway.search_by_assessment_id(assessment_id).first
    ViewModel::Export::DomesticExportView.new(wrapper, assessment)
  end

  def read_json_fixture(file_name)
    path = File.join(Dir.pwd, "spec/fixtures/json_export/#{file_name}.json")
    file = File.read(path)
    JSON.parse(file, symbolize_names: true)
  end
end
