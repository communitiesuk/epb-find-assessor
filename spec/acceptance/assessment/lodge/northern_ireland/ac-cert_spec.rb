# frozen_string_literal: true

describe "Acceptance::LodgeAC-CERTNIEnergyAssessment" do
  include RSpecRegisterApiServiceMixin

  let(:fetch_assessor_stub) { AssessorStub.new }

  let(:valid_cepc_ni_xml) do
    File.read File.join Dir.pwd, "spec/fixtures/samples/ac-cert-ni.xml"
  end

  context "when lodging an AC-CERT assessment (post)" do
    context "when an assessor is inactive" do
      let(:scheme_id) { add_scheme_and_get_id }

      before do
        add_assessor(
          scheme_id,
          "SPEC000000",
          fetch_assessor_stub.fetch_request_body(nonDomesticCc4: "INACTIVE"),
        )
      end

      context "when unqualified for AC-CERT" do
        it "returns status 400 with the correct error response" do
          response =
            JSON.parse(
              lodge_assessment(
                assessment_body: valid_cepc_ni_xml,
                accepted_responses: [400],
                auth_data: { scheme_ids: [scheme_id] },
                schema_name: "CEPC-NI-8.0.0",
              ).body,
            )

          expect(response["errors"][0]["title"]).to eq(
            "Assessor is not active.",
          )
        end
      end
    end

    it "returns status 201" do
      scheme_id = add_scheme_and_get_id
      add_assessor(
        scheme_id,
        "SPEC000000",
        fetch_assessor_stub.fetch_request_body(nonDomesticCc4: "ACTIVE"),
      )

      lodge_assessment(
        assessment_body: valid_cepc_ni_xml,
        accepted_responses: [201],
        auth_data: { scheme_ids: [scheme_id] },
        schema_name: "CEPC-NI-8.0.0",
      )
    end

    context "when saving a (AC-CERT) assessment" do
      let(:scheme_id) { add_scheme_and_get_id }
      let(:doc) { Nokogiri.XML valid_cepc_ni_xml }
      let(:response) do
        JSON.parse(fetch_assessment("0000-0000-0000-0000-0000").body)
      end

      before do
        add_assessor(
          scheme_id,
          "SPEC000000",
          fetch_assessor_stub.fetch_request_body(nonDomesticCc4: "ACTIVE"),
        )
      end

      it "returns the data that was lodged" do
        lodge_assessment(
          assessment_body: doc.to_xml,
          accepted_responses: [201],
          auth_data: { scheme_ids: [scheme_id] },
          schema_name: "CEPC-NI-8.0.0",
        )

        expected_response = {
          "addressId" => "UPRN-000000000000",
          "addressLine1" => "2 Lonely Street",
          "addressLine2" => "",
          "addressLine3" => "",
          "addressLine4" => "",
          "assessmentId" => "0000-0000-0000-0000-0000",
          "assessor" => {
            "contactDetails" => {
              "email" => "person@person.com",
              "telephoneNumber" => "010199991010101",
            },
            "dateOfBirth" => "1991-02-25",
            "firstName" => "Someone",
            "lastName" => "Person",
            "middleNames" => "Muddle",
            "qualifications" => {
              "domesticSap" => "INACTIVE",
              "domesticRdSap" => "INACTIVE",
              "nonDomesticCc4" => "ACTIVE",
              "nonDomesticSp3" => "INACTIVE",
              "nonDomesticDec" => "INACTIVE",
              "nonDomesticNos3" => "INACTIVE",
              "nonDomesticNos4" => "INACTIVE",
              "nonDomesticNos5" => "INACTIVE",
              "gda" => "INACTIVE",
            },
            "address" => {},
            "companyDetails" => {},
            "registeredBy" => {
              "name" => "test scheme", "schemeId" => scheme_id
            },
            "schemeAssessorId" => "SPEC000000",
            "searchResultsComparisonPostcode" => "",
          },
          "currentCarbonEmission" => 0.0,
          "currentEnergyEfficiencyBand" => "a",
          "currentEnergyEfficiencyRating" => 99,
          "optOut" => false,
          "dateOfAssessment" => "2020-05-04",
          "dateOfExpiry" => "2030-05-04",
          "dateRegistered" => "2020-05-04",
          "dwellingType" => "Property-Type1",
          "heatDemand" => {
            "currentSpaceHeatingDemand" => 0.0,
            "currentWaterHeatingDemand" => 0.0,
            "impactOfCavityInsulation" => nil,
            "impactOfLoftInsulation" => nil,
            "impactOfSolidWallInsulation" => nil,
          },
          "postcode" => "A0 0AA",
          "potentialCarbonEmission" => 0.0,
          "potentialEnergyEfficiencyBand" => "a",
          "potentialEnergyEfficiencyRating" => 99,
          "totalFloorArea" => 0.0,
          "town" => "Post-Town1",
          "typeOfAssessment" => "AC-CERT",
          "relatedPartyDisclosureNumber" => nil,
          "relatedPartyDisclosureText" => nil,
          "recommendedImprovements" => [],
          "propertySummary" => [],
          "relatedAssessments" => [
            {
              "assessmentExpiryDate" => "2030-05-04",
              "assessmentId" => "0000-0000-0000-0000-0000",
              "assessmentStatus" => "ENTERED",
              "assessmentType" => "AC-CERT",
            },
          ],
          "status" => "ENTERED",
        }

        expect(response["data"]).to eq(expected_response)
      end
    end
  end
end