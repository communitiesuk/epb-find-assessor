describe UseCase::ExportOpenDataCepcrr do
  include RSpecRegisterApiServiceMixin
  context "when creating the open data reporting release" do
    describe "for the CEPC recommendation reports" do
      let(:number_of_recommendations_returned) { 5 }
      let(:expected_values) { Samples::ViewModels::CepRr.report_test_hash }
      let(:date_today) { DateTime.now.strftime("%F") }
      let(:exported_data) { described_class.new.execute("2019-07-01") }

      let(:ni_cepc_plus_rr) do
        xml = Nokogiri.XML Samples.xml("CEPC-8.0.0", "cepc+rr")
        xml
            .xpath("//*[local-name() = 'RRN']")
            .each_with_index do |node, index|
          node.content = "1111-0000-0000-0000-000#{index}"
        end

        xml
            .xpath("//*[local-name() = 'Related-RRN']")
            .reverse
            .each_with_index do |node, index|
          node.content = "1111-0000-0000-0000-000#{index}"
        end

        xml
            .xpath("//*[local-name() = 'Postcode']")
            .reverse
            .each do |node|
          node.content = "BT1 2TD"
        end

        xml
      end

      let(:cepc_plus_rr_pre_2019) do
        xml = Nokogiri.XML Samples.xml("CEPC-8.0.0", "cepc+rr")
        xml
            .xpath("//*[local-name() = 'RRN']")
            .each_with_index do |node, index|
          node.content = "1111-0000-0000-0000-000#{index + 2}"
        end

        xml
            .xpath("//*[local-name() = 'Related-RRN']")
            .reverse
            .each_with_index do |node, index|
          node.content = "1111-0000-0000-0000-000#{index + 2}"
        end

        xml
            .xpath("//*[local-name() = 'Registration-Date']")
            .reverse
            .each do |node|
          node.content = "2018-07-01"
        end

        xml
      end

      before(:example) do
        scheme_id = add_scheme_and_get_id
        cepc_plus_rr_xml = Nokogiri.XML Samples.xml("CEPC-8.0.0", "cepc+rr")
        rr_minus_cepc_xml = Nokogiri.XML Samples.xml("CEPC-8.0.0", "cepc-rr") # should not be present in export
        rr_minus_cepc_xml_id = rr_minus_cepc_xml.at("//CEPC:RRN")

        add_assessor(
          scheme_id,
          "SPEC000000",
          AssessorStub.new.fetch_request_body(
            nonDomesticNos3: "ACTIVE",
            nonDomesticNos4: "ACTIVE",
            nonDomesticNos5: "ACTIVE",
            nonDomesticDec: "ACTIVE",
            domesticRdSap: "ACTIVE",
            domesticSap: "ACTIVE",
            nonDomesticSp3: "ACTIVE",
            nonDomesticCc4: "ACTIVE",
            gda: "ACTIVE",
          ),
        )

        # create a lodgement for cepc whose date valid
        lodge_assessment(
            assessment_body: cepc_plus_rr_xml.to_xml,
            accepted_responses: [201],
            auth_data: {
                scheme_ids: [scheme_id],
            },
            override: true,
            schema_name: "CEPC-8.0.0",
            )

        # create a lodgement for cepc whose date is not valid
        lodge_assessment(
            assessment_body: cepc_plus_rr_pre_2019.to_xml,
            accepted_responses: [201],
            auth_data: {
                scheme_ids: [scheme_id],
            },
            override: true,
            schema_name: "CEPC-8.0.0",
            )

        # create a lodgement for cepc that should NOT be returned
        rr_minus_cepc_xml_id.children = "0000-0000-0000-0000-0010"
        lodge_assessment(
          assessment_body: rr_minus_cepc_xml.to_xml,
          accepted_responses: [201],
          auth_data: {
            scheme_ids: [scheme_id],
          },
          override: true,
          schema_name: "CEPC-8.0.0",
        )

        # create a lodgement for NI that should not be returned
        lodge_assessment(
          assessment_body: ni_cepc_plus_rr.to_xml,
          accepted_responses: [201],
          auth_data: { scheme_ids: [scheme_id] },
          override: true,
          schema_name: "CEPC-8.0.0",
          )
      end

      it "returns the correct number of recommendations excluding the cepc-rr, NI lodgements and any before the given date" do
        expect(exported_data.length).to eq(number_of_recommendations_returned)
      end

      it "returns recommendations in the following format" do
        expect(exported_data[0]).to eq cO2_Impact: "HIGH",
                                       payback_type: "short",
                                       recommendation:
                                           "Consider replacing T8 lamps with retrofit T5 conversion kit.",
                                       recommendation_code: "ECP-L5",
                                       recommendation_item: 1,
                                       rrn: "0000-0000-0000-0000-0001"
      end

      it "exports the data ordered by payback_type" do
        order_of_payback_type = exported_data.map do |recommendation|
          recommendation[:payback_type]
        end
        expect(order_of_payback_type).to eq ["short", "short", "medium", "long", "other"]
      end
    end
  end
end
