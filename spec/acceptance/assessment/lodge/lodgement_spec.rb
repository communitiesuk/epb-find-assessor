# frozen_string_literal: true

describe "Acceptance::Assessment::Lodge" do
  include RSpecRegisterApiServiceMixin

  let(:valid_assessor_request_body) do
    AssessorStub.new.fetch_request_body(
      domesticRdSap: "ACTIVE", nonDomesticNos3: "ACTIVE",
    )
  end

  let(:valid_rdsap_xml) do
    File.read File.join Dir.pwd, "spec/fixtures/samples/rdsap.xml"
  end

  let(:valid_cepc_rr_xml) do
    File.read File.join Dir.pwd, "spec/fixtures/samples/cepc+rr.xml"
  end

  context "when lodging an energy assessment (post)" do
    it "rejects an assessment with a schema that does not exist" do
      lodge_assessment(
        assessment_body: valid_rdsap_xml,
        accepted_responses: [400],
        schema_name: "MakeupSAP-20.0.0",
      )
    end

    context "when an assessor is not registered" do
      it "returns status 400" do
        lodge_assessment(
          assessment_body: valid_rdsap_xml, accepted_responses: [400],
        )
      end

      it "returns status 400 with the correct error response" do
        response =
          JSON.parse(
            lodge_assessment(
              assessment_body: valid_rdsap_xml, accepted_responses: [400],
            ).body,
          )

        expect(response["errors"][0]["title"]).to eq(
          "Assessor is not registered.",
        )
      end
    end

    it "returns 401 with no authentication" do
      lodge_assessment(
        assessment_body: "body", accepted_responses: [401], authenticate: false,
      )
    end

    it "returns 403 with incorrect scopes" do
      lodge_assessment(
        assessment_body: "body",
        accepted_responses: [403],
        auth_data: { scheme_ids: {} },
        scopes: %w[wrong:scope],
      )
    end

    it "returns 403 if it is being lodged by the wrong scheme" do
      scheme_id = add_scheme_and_get_id
      add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)
      different_scheme_id = add_scheme_and_get_id("BADSCHEME")

      lodge_assessment(
        assessment_body: valid_rdsap_xml,
        accepted_responses: [403],
        auth_data: { scheme_ids: [different_scheme_id] },
      )
    end

    it "returns the correct response" do
      scheme_id = add_scheme_and_get_id
      add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)

      response =
        JSON.parse(
          lodge_assessment(
            assessment_body: valid_rdsap_xml,
            accepted_responses: [201],
            auth_data: { scheme_ids: [scheme_id] },
          ).body,
          symbolize_names: true,
        )

      expect(response).to eq(
        {
          data: { assessments: %w[0000-0000-0000-0000-0000] },
          meta: {
            links: {
              assessments: %w[/api/assessments/0000-0000-0000-0000-0000],
            },
          },
        },
      )
    end

    context "when schema is not supported" do
      let(:scheme_id) { add_scheme_and_get_id }
      let(:doc) { Nokogiri.XML valid_rdsap_xml }

      before do
        add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)
      end

      it "returns status 400" do
        lodge_assessment(
          assessment_body: doc.to_xml,
          accepted_responses: [400],
          auth_data: { scheme_ids: [scheme_id] },
          schema_name: "unsupported",
        )
      end

      it "returns the correct error message" do
        response =
          JSON.parse(
            lodge_assessment(
              assessment_body: doc.to_xml,
              accepted_responses: [400],
              auth_data: { scheme_ids: [scheme_id] },
              schema_name: "unsupported",
            ).body,
          )

        expect(response["errors"][0]["title"]).to eq("Schema is not supported.")
      end
    end

    context "when saving an assessment" do
      let(:scheme_id) { add_scheme_and_get_id }
      let(:doc) { Nokogiri.XML valid_rdsap_xml }
      let(:response) do
        JSON.parse(fetch_assessment("0000-0000-0000-0000-0000").body)
      end

      before do
        add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)
      end

      context "when an assessment already exists with the same assessment id" do
        it "returns status 409" do
          lodge_assessment(
            assessment_body: doc.to_xml,
            accepted_responses: [201],
            auth_data: { scheme_ids: [scheme_id] },
          )

          lodge_assessment(
            assessment_body: doc.to_xml,
            accepted_responses: [409],
            auth_data: { scheme_ids: [scheme_id] },
          )
        end
      end
    end

    context "when rejecting an assessment" do
      it "rejects an assessment with an incorrect element" do
        scheme_id = add_scheme_and_get_id
        add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)

        doc = Nokogiri.XML valid_rdsap_xml

        scheme_assessor_id = doc.at("Address")
        scheme_assessor_id.children = "<Postcode>invalid</Postcode>"

        response_body =
          JSON.parse(
            lodge_assessment(
              assessment_body: doc.to_xml, accepted_responses: [400],
            ).body,
          )

        expect(
          response_body["errors"][0]["title"],
        ).to include "This element is not expected."
      end

      it "rejects an assessment with invalid XML" do
        xml = valid_rdsap_xml

        xml = xml.gsub("<Energy-Assessment>", "<Energy-Assessment")

        response_body =
          JSON.parse(
            lodge_assessment(assessment_body: xml, accepted_responses: [400])
              .body,
          )

        expect(
          response_body["errors"][0]["title"],
        ).to include "Invalid attribute name: <<Property-Summary>"
      end
    end
  end

  context "when an unauthenticated migration request is made" do
    let(:scheme_id) { add_scheme_and_get_id }

    let(:response) do
      JSON.parse(
        lodge_assessment(
          assessment_body: valid_rdsap_xml,
          accepted_responses: [403],
          auth_data: { scheme_ids: [scheme_id] },
          migrated: true,
        ).body,
        symbolize_names: true,
      )
    end

    before { add_assessor scheme_id, "SPEC000000", valid_assessor_request_body }

    it "shows the correct error response" do
      expect(response).to eq(
        {
          errors: [
            {
              code: "UNAUTHORISED",
              title: "You are not authorised to perform this request",
            },
          ],
        },
      )
    end
  end

  context "when lodging an energy assessment" do
    let(:scheme_id) { add_scheme_and_get_id }

    let(:migrated_column) do
      ActiveRecord::Base.connection.execute(
        "SELECT migrated FROM assessments WHERE assessment_id = '0000-0000-0000-0000-0000'",
      )
    end

    before { add_assessor scheme_id, "SPEC000000", valid_assessor_request_body }

    context "with migrated parameter" do
      before do
        lodge_assessment assessment_body: valid_rdsap_xml,
                         accepted_responses: [201],
                         scopes: %w[assessment:lodge migrate:assessment],
                         auth_data: { scheme_ids: [scheme_id] },
                         migrated: true
      end

      it "should be true in migrated column" do
        expect(migrated_column.entries.first["migrated"]).to be_truthy
      end

      context "when migrating the same assessment ID" do
        before do
          lodge_assessment assessment_body: valid_rdsap_xml,
                           accepted_responses: [201],
                           scopes: %w[assessment:lodge migrate:assessment],
                           auth_data: { scheme_ids: [scheme_id] },
                           migrated: true
        end

        it "should be true in migrated column" do
          expect(migrated_column.entries.first["migrated"]).to be_truthy
        end
      end

      context "when migrating an assessment submitted by an assessor who is now unqualified" do
        let(:rdsap_xml) do
          add_assessor scheme_id,
                       "UNQU000000",
                       AssessorStub.new.fetch_request_body(
                         domesticRdSap: "INACTIVE",
                       )

          xml = Nokogiri.XML valid_rdsap_xml

          xml.css("Certificate-Number").children.first.content = "UNQU000000"

          xml.to_s
        end

        it "should be true in migrated column" do
          lodge_assessment assessment_body: rdsap_xml,
                           accepted_responses: [201],
                           scopes: %w[assessment:lodge migrate:assessment],
                           auth_data: { scheme_ids: [scheme_id] },
                           migrated: true
        end
      end
    end

    context "without migrated parameter" do
      before do
        lodge_assessment assessment_body: valid_rdsap_xml,
                         accepted_responses: [201],
                         auth_data: { scheme_ids: [scheme_id] }
      end

      it "shows false in the migrated column" do
        expect(migrated_column.entries.first["migrated"]).to be_falsey
      end
    end
  end

  context "when lodging two energy assessments" do
    let(:scheme_id) { add_scheme_and_get_id }

    let(:response) do
      JSON.parse(
        lodge_assessment(
          assessment_body: valid_cepc_rr_xml,
          accepted_responses: [201],
          auth_data: { scheme_ids: [scheme_id] },
          schema_name: "CEPC-8.0.0",
        ).body,
        symbolize_names: true,
      )
    end

    before do
      add_assessor scheme_id,
                   "SPEC000000",
                   AssessorStub.new.fetch_request_body(
                     nonDomesticNos3: "ACTIVE",
                   )
    end

    it "returns the correct response" do
      expect(response).to eq(
        {
          data: {
            assessments: %w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001],
          },
          meta: {
            links: {
              assessments: %w[
                /api/assessments/0000-0000-0000-0000-0000
                /api/assessments/0000-0000-0000-0000-0001
              ],
            },
          },
        },
      )
    end
  end

  context "when lodging an assessment with current and potential costs of more than 2 dp" do
    let(:response) do
      JSON.parse(fetch_assessment("0000-0000-0000-0000-0000").body)
    end

    let(:lighting_cost_current) do
      ActiveRecord::Base.connection.execute(
        "SELECT lighting_cost_current FROM assessments WHERE assessment_id = '0000-0000-0000-0000-0000'",
      )
    end

    let(:lighting_cost_potential) do
      ActiveRecord::Base.connection.execute(
        "SELECT lighting_cost_potential FROM assessments WHERE assessment_id = '0000-0000-0000-0000-0000'",
      )
    end

    before do
      scheme_id = add_scheme_and_get_id
      add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)

      doc = Nokogiri.XML valid_rdsap_xml

      scheme_assessor_id = doc.at("Energy-Use")
      scheme_assessor_id.children =
        '<Energy-Rating-Average>60</Energy-Rating-Average>
      <Energy-Rating-Current>66</Energy-Rating-Current>
      <Energy-Rating-Potential>80</Energy-Rating-Potential>
      <Environmental-Impact-Current>61</Environmental-Impact-Current>
      <Environmental-Impact-Potential>75</Environmental-Impact-Potential>
      <Energy-Consumption-Current>231</Energy-Consumption-Current>
      <Energy-Consumption-Potential>141</Energy-Consumption-Potential>
      <CO2-Emissions-Current>4.2</CO2-Emissions-Current>
      <CO2-Emissions-Potential>2.6</CO2-Emissions-Potential>
      <CO2-Emissions-Current-Per-Floor-Area>41</CO2-Emissions-Current-Per-Floor-Area>
      <Lighting-Cost-Current currency="GBP">173.76829628</Lighting-Cost-Current>
      <Lighting-Cost-Potential currency="GBP">0</Lighting-Cost-Potential>
      <Heating-Cost-Current currency="GBP">745</Heating-Cost-Current>
      <Heating-Cost-Potential currency="GBP">681</Heating-Cost-Potential>
      <Hot-Water-Cost-Current currency="GBP">113</Hot-Water-Cost-Current>
      <Hot-Water-Cost-Potential currency="GBP">77</Hot-Water-Cost-Potential>'

      JSON.parse(
        lodge_assessment(
          assessment_body: doc.to_xml,
          accepted_responses: [201],
          auth_data: { scheme_ids: [scheme_id] },
        ).body,
        symbolize_names: true,
      )
    end

    it "is stored in the database with 2 dp" do
      expect(response["data"]["lightingCostCurrent"]).to include "173.77"
    end

    it "returns a fetched response with 2 dp" do
      expect(
        lighting_cost_current.entries.first["lighting_cost_current"],
      ).to include "173.77"
    end

    it "is stored in the database with 0" do
      expect(response["data"]["lightingCostPotential"]).to include "0"
    end

    it "returns a fetched response with 2 dp" do
      expect(
        lighting_cost_potential.entries.first["lighting_cost_potential"],
      ).to eq "0.00"
    end
  end

  context "when lodging an assessment with the override flag set to true" do
    let(:valid_cepc_xml) do
      File.read File.join Dir.pwd, "spec/fixtures/samples/cepc.xml"
    end

    let(:cepc_xml_doc) do
      cepc_xml_doc = Nokogiri.XML(valid_cepc_xml)
      cepc_xml_doc
    end

    it "will lodge the assessment and log the events to the overidden_lodgement_events table" do
      scheme_id = add_scheme_and_get_id
      add_assessor(scheme_id, "SPEC000000", valid_assessor_request_body)

      cepc_xml_doc.at("//CEPC:Registration-Date").children = "2030-05-04"

      lodge_assessment(
        assessment_body: cepc_xml_doc.to_xml,
        accepted_responses: [201],
        auth_data: { scheme_ids: [scheme_id] },
        schema_name: "CEPC-8.0.0",
        override: true,
      )

      overidden_lodgement_event =
        ActiveRecord::Base.connection.execute(
          "SELECT * FROM overidden_lodgement_events WHERE assessment_id = '0000-0000-0000-0000-0000'",
        ).first

      expect(overidden_lodgement_event["assessment_id"]).to eq(
        "0000-0000-0000-0000-0000",
      )
      expect(overidden_lodgement_event["rule_triggers"]).to eq(
        "[{\"code\": \"DATES_CANT_BE_IN_FUTURE\", \"title\": \"Inspection-Date\\\", \\\"Registration-Date\\\", \\\"Issue-Date\\\", \\\"Effective-Date\\\", \\\"OR-Availability-Date\\\", \\\"Start-Date\\\" and \\\"OR-Assessment-Start-Date\\\" must not be in the future\"}]",
      )
    end
  end

  context "when lodging all assessment types" do
    def sample(name)
      File.read File.join Dir.pwd, "spec/fixtures/samples/" + name + ".xml"
    end

    def response(name)
      JSON.parse((File.read File.join Dir.pwd, "spec/fixtures/responses/" + name + ".json"), symbolize_names: true)
    end

    let(:scheme_id) { add_scheme_and_get_id }

    def create_assessor(qualifications)
      add_assessor(
        scheme_id,
        "SPEC000000",
        AssessorStub.new.fetch_request_body(qualifications),
      )
    end

    assessments = {
      "CEPC-8.0.0": {
        "valid_cepc": {
          xml: "cepc",
          assessor_qualification: {
            nonDomesticNos3: "ACTIVE",
            nonDomesticNos4: "ACTIVE",
            nonDomesticNos5: "ACTIVE",
          },
          response_code: [201],
          expected_response: "lodgement",
        },
      },
    }

    assessments.each do |schema_name, assessments|
      context "when lodging with schema " + schema_name.to_s do
        assessments.each do |assessment_name, assessment_settings|
          it "tries to lodge a " + assessment_name.to_s + " with response code " + assessment_settings[:response_code].join(", ") do
            create_assessor(assessment_settings[:assessor_qualification])

            lodgement_response =
              JSON.parse(
                lodge_assessment(
                  assessment_body: sample(assessment_settings[:xml]),
                  accepted_responses: assessment_settings[:response_code],
                  auth_data: { scheme_ids: [scheme_id] },
                  schema_name: schema_name.to_s,
                  ).body,
                symbolize_names: true,
              )

            if assessment_settings[:expected_response]
              expect(lodgement_response).to eq(response(assessment_settings[:expected_response]))
            end
          end
        end
      end
    end
  end
end
