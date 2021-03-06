describe "FixBlankAssessors" do
  include RSpecRegisterApiServiceMixin

  let(:scheme_id) { add_scheme_and_get_id }
  let(:scheme_assessor_id) { "SPEC000000" }
  let(:sap_schema) { "SAP-Schema-18.0.0".freeze }
  let(:sap_xml) { Nokogiri.XML Samples.xml(sap_schema, "epc") }

  context "When a lodging assessor exists and has no name" do
    before do
      allow(STDOUT).to receive(:puts)
      add_assessor(
        scheme_id,
        scheme_assessor_id,
        {
          firstName: "",
          middleNames: "",
          lastName: "",
          dateOfBirth: "1970-01-01",
          searchResultsComparisonPostcode: "",
          qualifications: {
            nonDomesticNos3: "INACTIVE",
            nonDomesticNos4: "INACTIVE",
            nonDomesticNos5: "INACTIVE",
            nonDomesticDec: "INACTIVE",
            domesticRdSap: "INACTIVE",
            domesticSap: "INACTIVE",
            nonDomesticSp3: "INACTIVE",
            nonDomesticCc4: "INACTIVE",
            gda: "INACTIVE",
          },
          contactDetails: {
            telephoneNumber: "",
            email: "fake@email.org",
          },
        },
      )
      call_lodge_assessment(scheme_id: scheme_id, schema_name: sap_schema, xml_document: sap_xml, migrated: true)
    end

    it "outputs one updated assessors" do
      expect { get_task("fix_blank_assessors").invoke }.to output(
        /1 records updated and 0 records skipped/,
      ).to_stdout
    end

    it "updates the assessor first_name" do
      get_task("fix_blank_assessors").invoke

      response = JSON.parse(fetch_assessor(scheme_id, scheme_assessor_id).body)
      expect(response["data"]["firstName"]).to eq("Mr Test Boi TST")
      expect(response["data"]["lastName"]).to eq("")
    end
  end

  context "When a lodging assessor exists and has a name" do
    before do
      allow(STDOUT).to receive(:puts)
      add_assessor(
        scheme_id,
        scheme_assessor_id,
        {
          firstName: "John",
          middleNames: "",
          lastName: "Smith",
          dateOfBirth: "1970-01-01",
          searchResultsComparisonPostcode: "",
          qualifications: {
            nonDomesticNos3: "INACTIVE",
            nonDomesticNos4: "INACTIVE",
            nonDomesticNos5: "INACTIVE",
            nonDomesticDec: "INACTIVE",
            domesticRdSap: "INACTIVE",
            domesticSap: "INACTIVE",
            nonDomesticSp3: "INACTIVE",
            nonDomesticCc4: "INACTIVE",
            gda: "INACTIVE",
          },
          contactDetails: {
            telephoneNumber: "",
            email: "fake@email.org",
          },
        },
      )
      call_lodge_assessment(scheme_id: scheme_id, schema_name: sap_schema, xml_document: sap_xml, migrated: true)
    end

    it "outputs zero updated assessors" do
      expect { get_task("fix_blank_assessors").invoke }.to output(
        /0 records updated and 0 records skipped/,
      ).to_stdout
    end

    it "does not update the assessor" do
      get_task("fix_blank_assessors").invoke

      response = JSON.parse(fetch_assessor(scheme_id, scheme_assessor_id).body)
      expect(response["data"]["firstName"]).to eq("John")
      expect(response["data"]["lastName"]).to eq("Smith")
    end
  end

  context "When a lodging assessor exists, assessor has no name on any assessments" do
    before do
      allow(STDOUT).to receive(:puts)
      add_assessor(
        scheme_id,
        scheme_assessor_id,
        {
          firstName: "",
          middleNames: "",
          lastName: "",
          dateOfBirth: "1970-01-01",
          searchResultsComparisonPostcode: "",
          qualifications: {
            nonDomesticNos3: "INACTIVE",
            nonDomesticNos4: "INACTIVE",
            nonDomesticNos5: "INACTIVE",
            nonDomesticDec: "INACTIVE",
            domesticRdSap: "INACTIVE",
            domesticSap: "INACTIVE",
            nonDomesticSp3: "INACTIVE",
            nonDomesticCc4: "INACTIVE",
            gda: "INACTIVE",
          },
          contactDetails: {
            telephoneNumber: "",
            email: "fake@email.org",
          },
        },
      )
      corrected_sap_xml = sap_xml
      corrected_sap_xml.at("Home-Inspector Name").children = ""
      call_lodge_assessment(scheme_id: scheme_id, schema_name: sap_schema, xml_document: corrected_sap_xml, migrated: true)
    end

    it "outputs one record skipped" do
      expect { get_task("fix_blank_assessors").invoke }.to output(
        /0 records updated and 1 records skipped/,
      ).to_stdout
    end

    it "does not update the assessor" do
      get_task("fix_blank_assessors").invoke

      response = JSON.parse(fetch_assessor(scheme_id, scheme_assessor_id).body)
      expect(response["data"]["firstName"]).to eq("")
      expect(response["data"]["lastName"]).to eq("")
    end
  end
end
