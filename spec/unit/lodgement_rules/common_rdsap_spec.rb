describe LodgementRules::DomesticCommon do
  let(:docs_under_test) do
    [
      {
        xml_doc:
          Nokogiri.XML(
            File.read(File.join(Dir.pwd, "spec/fixtures/samples/rdsap.xml")),
          ),
        schema_name: "RdSAP-Schema-20.0.0",
      },
      {
        xml_doc:
          Nokogiri.XML(
            File.read(File.join(Dir.pwd, "spec/fixtures/samples/rdsap-ni.xml")),
          ),
        schema_name: "RdSAP-Schema-NI-20.0.0",
      },
    ]
  end

  def assert_errors(key, value, errors)
    docs_under_test.each do |doc|
      xml_doc = doc[:xml_doc]
      xml_doc.at(key).children = value

      wrapper =
        ViewModel::Factory.new.create(
          xml_doc.to_xml,
          "RdSAP-Schema-20.0.0",
          false,
          true,
        )
      adapter = wrapper.get_view_model
      errors = described_class.new.validate(adapter)
      expect(errors).to match_array(errors)
    end
  end

  it "Returns an empty list for a valid file" do
    docs_under_test.each do |doc|
      wrapper =
        ViewModel::Factory.new.create(
          doc[:xml_doc].to_xml,
          doc[:schema_name],
          false,
          true,
        )
      adapter = wrapper.get_view_model
      errors = described_class.new.validate(adapter)
      expect(errors).to eq([])
    end
  end

  context "MUST_HAVE_HABITABLE_ROOMS" do
    let(:error) do
      {
        "code": "MUST_HAVE_HABITABLE_ROOMS",
        "title":
          '"Habitable-Room-Count" must be an integer and must be greater than or equal to 1',
      }.freeze
    end

    it "returns an error if the habitable room count is not an integer" do
      assert_errors("Habitable-Room-Count", "6.2", [error])
    end

    it "returns an error if the habitable room count is zero" do
      assert_errors("Habitable-Room-Count", "0", [error])
    end

    it "returns an error if the habitable room count is negative" do
      assert_errors("Habitable-Room-Count", "-2", [error])
    end
  end
end